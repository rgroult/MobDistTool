// Copyright (c) 2016, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:async';
import 'dart:core';
import 'package:rpc/rpc.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/src/body.dart';
import 'package:jwt/json_web_token.dart';
import 'dart:convert';
import '../managers/managers.dart' as mgrs;
import 'user_service.dart' as userService;
import 'model.dart';
import 'json_convertor.dart';
import '../config/config.dart' as config;
import '../utils/utils.dart' as utils;
import '../utils/lite_mem_cache.dart' as cache;

JsonWebTokenCodec jsonWebToken;

@ApiClass( name:'art' , version: 'v1')
class ArtifactService {

  static String lastVersionBranchName = "@@@@LAST####";
  static String lastVersionName = "latest";


  ArtifactService(){
    //jsonWebToken = new JsonWebTokenCodec(header: {}, secret: config.currentLoadedConfig[config.MDT_TOKEN_SECRET]);
  }
/*
Not used yet
  @ApiMethod(method: 'PUT', path: 'artifacts/{idArtifact}')
  Future<Response> addArtifact(String idArtifact,  FullArtifactMsg artifactsMsg) async{
    //current user
    var currentuser = userService.currentAuthenticatedUser();
    //artifact
    var artifact = await findArtifact(idArtifact);
    if (artifact == null ){
      return NotFoundError;
    }
    if (mgrs.isAdminForApp(artifact.application,currentuser) == false){
      throw new NotApplicationAdministrator();
    }
    artifact.branch = artifactsMsg.branch;
    artifact.version = artifactsMsg.version;
    artifact.artifactName = artifactsMsg.artifactName;

    if(artifactsMsg.sortIdentifier != null){
      artifact.sortIdentifier= artifactsMsg.sortIdentifier;
    }

    if(artifactsMsg.jsonTags != null){
      artifact.metaDataTags= parseTags(artifactsMsg.jsonTags);
    }

    if(artifactsMsg.artifactFile != null){
      try {
        mgrs.addFileToArtifact(artifactsMsg.artifactFile,artifactsMsg,mgrs.defaultStorage);
      }on ArtifactError catch(e){
        throw new RpcError(500, 'Update failed', 'Unable to update artifact');
      }
    }

    await artifact.save();
    return new Response(200, toJson(artifact,isAdmin:true));
  }*/

  @ApiMethod(method: 'DELETE', path: 'artifacts/{idArtifact}')
  Future<Response> deleteArtifact(String idArtifact) async{
    //current user
    var currentuser = userService.currentAuthenticatedUser();
    //artifact
    var artifact =  await mgrs.findArtifact(idArtifact);
    if (artifact == null ){
      throw new NotFoundError();
    }
    if (mgrs.isAdminForApp(artifact.application,currentuser) == false){
      throw new NotApplicationAdministrator();
    }
    try {
      await mgrs.deleteArtifact(artifact,mgrs.defaultStorage);
    }on ArtifactError catch(e){

    }
    return new OKResponse();
  }


  @ApiMethod(method: 'GET', path: 'artifacts/{idArtifact}/download')
  Future<Response> getArtifactDescriptor(String idArtifact) async{
    var artifact = await  mgrs.findArtifact(idArtifact);
    if (artifact == null ){
      throw new NotFoundError("Unable to find artifact");
    }
    var downloadInfo = new DownloadInfo();
    var baseArtifactPath = '/api/in/v1/artifacts/$idArtifact';
    if (config.currentLoadedConfig[config.MDT_SERVER_URL] != null){
      baseArtifactPath = '${config.currentLoadedConfig[config.MDT_SERVER_URL]}${baseArtifactPath}';
    }

    downloadInfo.directLinkUrl = '$baseArtifactPath/file';
    //add security web token
    DateTime now = new DateTime.now();
    now = now.add(new Duration(minutes: 3));
    final token = {
      'id':idArtifact,
      'expireAt': now.millisecondsSinceEpoch
    };
    var dwToken = cache.instance.addValue(token);

    downloadInfo.directLinkUrl = "${downloadInfo.directLinkUrl}?token=$dwToken";

    var app = await artifact.application.getMeFromDb();
    if (app == null){
      throw new NotFoundError("Unable to find application");
    }

    if (app.platform.toUpperCase() == 'IOS'){
      downloadInfo.installUrl = '$baseArtifactPath/ios_plist?token=$dwToken';
      downloadInfo.installUrl = "itms-services://?action=download-manifest&url=${Uri.encodeComponent(downloadInfo.installUrl)}";
    }else {
      downloadInfo.installUrl = downloadInfo.directLinkUrl;
    }
    return new Response(200, downloadInfo.toJson());
  }

  static Future downloadFile(String idArtifact,{String token}) async {
    try {
      //verify token
      Map tokenInfo = cache.instance.get(token);
      if (tokenInfo == null){
        throw new RpcError(401,"ARTIFACT_ERROR","Access expired");
      }
      DateTime now = new DateTime.now();
      DateTime validity = new DateTime.fromMillisecondsSinceEpoch(tokenInfo["expireAt"]);
      if (now.isAfter(validity)){
        throw new RpcError(401,"ARTIFACT_ERROR","Access expired");
      }

      var tokenArtifactId = tokenInfo["id"];
      //artifactID same as those in token
      if (idArtifact != tokenArtifactId){
        return new RpcError(401,"ARTIFACT_ERROR","Access denied");
      }

      var artifact = await mgrs.findArtifact(idArtifact);
      if (artifact == null){
        return new NotFoundError();
      }

      Stream stream = await mgrs.streamFromArtifact(artifact, mgrs.defaultStorage);
      var body = new Body(stream);
      var headers = {"Content-Type":artifact.contentType,"Content-length":"${artifact.size}","Content-Disposition":"attachment; filename=${artifact.filename}"};
      var response = new shelf.Response(200,body:body,headers:headers);
      //response.headers["content-type"]= artifact.contentType;
      //response.contentLength = artifact.size;
      return response;
    }on NotFoundError catch(e){
      return new shelf.Response.notFound("");
    }
    catch(e){
      print("downloadFile error:${e.toString()}");
      return new shelf.Response.internalServerError();
    }
  }
}
