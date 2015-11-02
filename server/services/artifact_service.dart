import 'dart:io';
import 'dart:async';
import 'package:rpc/rpc.dart';
import '../managers/managers.dart' as mgrs;
import 'user_service.dart' as userService;
import 'model.dart';
import 'json_convertor.dart';


@ApiClass( version: 'v1')
class ArtifactService {
  @ApiMethod(method: 'POST', path: 'artifacts/{apiKey}/versions')
  Future<Response> addArtifactByAppKey(String apiKey, ArtifactMsg artifactsMsg) async{
    var application = await mgrs.findApplicationByApiKey(apiKey);
    if (application == null){
      throw new NotFoundError('Application not found');
    }


    return new Response(500,{});
  }

  @ApiMethod(method: 'DELETE', path: 'artifacts/{apiKey}/versions')
  Future<Response> deleteArtifactByAppKey(String apiKey,{String version, String name}) async{
    var application = await mgrs.findApplicationByApiKey(apiKey);
    if (application == null){
      throw new NotFoundError('Application not found');
    }

    return new Response(500,{});
  }

  @ApiMethod(method: 'POST', path: 'artifacts/{apiKey}/versions/last')
  Future<Response> addLastArtifactByAppKey(String apiKey, ArtifactMsg artifactsMsg) async{
    var application = await mgrs.findApplicationByApiKey(apiKey);
    if (application == null){
      throw new NotFoundError('Application not found');
    }

    return new Response(500,{});
  }

  @ApiMethod(method: 'DELETE', path: 'artifacts/{apiKey}/versions/last')
  Future<Response> deleteLastArtifactByAppKey(String apiKey,{String version, String name}) async{
    var application = await mgrs.findApplicationByApiKey(apiKey);
    if (application == null){
      throw new NotFoundError('Application not found');
    }

    return new Response(500,{});
  }

  @ApiMethod(method: 'PUT', path: 'artifacts/{idArtifact}')
  Future<Response> addArtifact(String idArtifact,  ArtifactMsg artifactsMsg) async{

    return new Response(500,{});
  }

  @ApiMethod(method: 'DELETE', path: 'artifacts/{idArtifact}')
  Future<Response> deleteArtifact(String idArtifact,{bool lastVersion,String version, String name}) async{

    return new Response(500,{});
  }
}





//MDTApplication app,String name,String version, String branch,{String sortIdentifier, Map tags}