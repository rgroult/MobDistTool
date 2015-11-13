import 'dart:io';
import 'dart:async';
import 'package:rpc/rpc.dart';
import 'dart:convert';
import '../managers/managers.dart' as mgrs;
import 'user_service.dart' as userService;
import 'model.dart';
import 'json_convertor.dart';


@ApiClass( name:'art' , version: 'v1')
class ArtifactService {
  static String lastVersionBranchName = "@@@@LAST####";
  static String lastVersionName = "lastest";

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

  @ApiMethod(method: 'PUT', path: 'artifacts/{idArtifact}')
  Future<Response> addArtifact(String idArtifact,  FullArtifactMsg artifactsMsg) async{
    //current user
    var currentuser = userService.currentAuthenticatedUser();
    //artifact
    var artifact = findArtifact(idArtifact);
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
    var artifact = findArtifact(idArtifact);
    if (artifact == null ){
      return NotFoundError;
    }
    if (mgrs.isAdminForApp(artifact.application,currentuser) == false){
      throw new NotApplicationAdministrator();
    }
    try {
      await mgrs.deleteArtifact(artifact,,mgrs.defaultStorage);
    }on ArtifactError catch(e){

    }
    return new OKResponse();
  }

  String parseTags(String tags){
    if (tags == null){
      return null;
    }
    var object =  JSON.decode(tags);
    if (object != null){
      return JSON.encode(object);
    }
    return null;
  }
}
