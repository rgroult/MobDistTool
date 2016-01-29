import 'dart:io';
import 'dart:async';
import 'package:rpc/rpc.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/src/body.dart';
import 'dart:convert';
import '../managers/managers.dart' as mgrs;
import 'user_service.dart' as userService;
import 'model.dart';
import 'json_convertor.dart';


@ApiClass( name:'art' , version: 'v1')
class ArtifactService {

  static String lastVersionBranchName = "@@@@LAST####";
  static String lastVersionName = "latest";
/*
  @ApiMethod(method: 'POST', path: 'artifacts/{apiKey}/{branch}/{version}/{artifactName}')
  Future<Response> addArtifactByAppKey(String apiKey,String branch,String version, String artifactName, ArtifactMsg artifactsMsg) async{
    var application = await mgrs.findApplicationByApiKey(apiKey);
    var mediaMsg = artifactsMsg.artifactFile;
    if (application == null){
      throw new NotFoundError('Application not found');
    }

    //find existng artifact
    var existingArtifact = await mgrs.findArtifactByInfos(application,branch,version,artifactName);
    if (existingArtifact != null) {
      throw new RpcError(400, 'Already Exist', 'artifact exist with provided infos');
    }

    var parsedTags = null;
    if (artifactsMsg.jsonTags != null){
      parsedTags= parseTags(artifactsMsg.jsonTags);
    }
    var createdArtifact = await mgrs.createArtifact(application,artifactName,version,branch,sortIdentifier:artifactsMsg.sortIdentifier,tags:parsedTags);
    //add file
    try {
      //Create temp file
      var tempDir = Directory.systemTemp.createTempSync("art");
      var tempFile = await new File(artifactName).writeAsBytes(mediaMsg.bytes,flush:true);
      await mgrs.addFileToArtifact(tempFile,createdArtifact,mgrs.defaultStorage);
    }on ArtifactError catch(e){
      //delete created artifact
      await mgrs.deleteArtifact(createdArtifact,mgrs.defaultStorage);
      throw new RpcError(500, 'Add Error', 'Unable to add artifact')
        ..errors.add(new RpcErrorDetail(reason: e.message));
    }

    var jsonResponse = toJson(createdArtifact,isAdmin:true);
    return new Response(200, toJson(createdArtifact,isAdmin:true));
  }

  @ApiMethod(method: 'DELETE', path: 'artifacts/{apiKey}/{branch}/{version}/{artifactName}')
  Future<Response> deleteArtifactByAppKey(String apiKey,String branch,String version, String artifactName) async{
    var application = await mgrs.findApplicationByApiKey(apiKey);
    if (application == null){
      throw new NotFoundError('Application not found');
    }
    var existingArtifact = await mgrs.findArtifactByInfos(app,branch,version,artifactName);
    if (existingArtifact != null) {
        await mgrs.deleteArtifact(existingArtifact,mgrs.defaultStorage);
    }
    return new OKResponse();
  }

  @ApiMethod(method: 'POST', path: 'artifacts/{apiKey}/last/{artifactName}')
  Future<Response> addLastArtifactByAppKey(String apiKey, String artifactName, ArtifactMsg artifactsMsg) async{
    return addArtifactByAppKey(apiKey,lastVersionBranchName, lastVersionName, artifactName, artifactsMsg);
  }

  @ApiMethod(method: 'DELETE', path: 'artifacts/{apiKey}/last/{artifactName}')
  Future<Response> deleteLastArtifactByAppKey(String apiKey,String artifactName) async{
    return deleteArtifactByAppKey(apiKey,lastVersionBranchName, lastVersionName,artifactName);
  }
*/
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
  }

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
    downloadInfo.directLinkUrl = '/in/v1/artifacts/$idArtifact/file';
    var app = await artifact.application.getMeFromDb();
    if (app == null){
      throw new NotFoundError("Unable to find application");
    }
    if (app.platform.toUpperCase() == 'IOS'){
      downloadInfo.installUrl = '/in/v1/artifacts/$idArtifact/ios_plist';
      downloadInfo.installScheme = "itms-services://?action=download-manifest&url=";
    }else {
      downloadInfo.installUrl = downloadInfo.directLinkUrl;
    }
    return new Response(200, downloadInfo.toJson());
  }

  static Future downloadFile(String idArtifact,{String token}) async {
    try {
      var artifact = await mgrs.findArtifact(idArtifact);
      if (artifact == null){
        throw new NotFoundError();
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
      return new shelf.Response.internalServerError();
    }
  }
}
