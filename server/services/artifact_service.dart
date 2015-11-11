import 'dart:io';
import 'dart:async';
import 'package:rpc/rpc.dart';
import '../managers/managers.dart' as mgrs;
import 'user_service.dart' as userService;
import 'model.dart';
import 'json_convertor.dart';


@ApiClass( name:'art' , version: 'v1')
class ArtifactService {
  @ApiMethod(method: 'POST', path: 'artifacts/{apiKey}/{branch}/{version}/{artifactName}')
  Future<Response> addArtifactByAppKey(String apiKey,String branch,String version, String artifactName, ArtifactMsg artifactsMsg) async{
    var application = await mgrs.findApplicationByApiKey(apiKey);
    var file = artifactsMsg.file;
    if (application == null){
      throw new NotFoundError('Application not found');
    }

    //find existng artifact
    var existingArtifact = await mgrs.findArtifactByInfos(app,branch,version,artifactName,mgrs.defaultStorage);
    if (existingArtifact != null) {
      throw new RpcError(400, 'Already Exist', 'artifact exist with provided infos');
    }

    var parsedTags = null
    if (artifactsMsg.jsonTags != null){
      //parse string to map
      //parsedTags = JSON.de
    }
    var createdArtifact = await mgrs.createArtifact(app,artifactName,version,branch,sortIdentifier:artifactsMsg.sortIdentifier,tags:parsedTags,mgrs.defaultStorage);
    //add file
    try {
      await mgrs.addFileToArtifact(artifactsMsg.artifactFile,createdArtifact,mgrs.defaultStorage);
    }on ArtifactError catch(e){
      //delete created artifact
      mgrs.deleteArtifact(createdArtifact,mgrs.defaultStorage);
      throw new RpcError(500, 'Add Error', 'Unable to add artifact')
        ..errors.add(new RpcErrorDetail(reason: e.message));
    }

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
    var application = await mgrs.findApplicationByApiKey(apiKey);
    if (application == null){
      throw new NotFoundError('Application not found');
    }

    return new Response(500,{});
  }

  @ApiMethod(method: 'DELETE', path: 'artifacts/{apiKey}/last/{artifactName}')
  Future<Response> deleteLastArtifactByAppKey(String apiKey,String artifactName) async{
    var application = await mgrs.findApplicationByApiKey(apiKey);
    if (application == null){
      throw new NotFoundError('Application not found');
    }

    return new Response(500,{});
  }

  @ApiMethod(method: 'PUT', path: 'artifacts/{idArtifact}')
  Future<Response> addArtifact(String idArtifact,  FullArtifactMsg artifactsMsg) async{

    return new Response(500,{});
  }

  @ApiMethod(method: 'DELETE', path: 'artifacts/{idArtifact}')
  Future<Response> deleteArtifact(String idArtifact) async{

    return new Response(500,{});
  }
}





//MDTApplication app,String name,String version, String branch,{String sortIdentifier, Map tags}