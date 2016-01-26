import 'dart:io';
import 'dart:async';
import 'package:rpc/rpc.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../managers/managers.dart' as mgrs;
import '../managers/errors.dart';
import 'user_service.dart' as userService;
import 'application_service.dart' as appService;
import 'artifact_service.dart';
import 'model.dart';
import 'json_convertor.dart';


@ApiClass( name:'in' , version: 'v1')
class InService {

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
      throw new RpcError(500, 'Add Error', 'Unable to add artifact: ${e.message}');
       // ..errors.add(new RpcErrorDetail(reason: e.message));
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
    return addArtifactByAppKey(apiKey, ArtifactService.lastVersionBranchName, ArtifactService.lastVersionName, artifactName, artifactsMsg);
  }

  @ApiMethod(method: 'DELETE', path: 'artifacts/{apiKey}/last/{artifactName}')
  Future<Response> deleteLastArtifactByAppKey(String apiKey,String artifactName) async{
    return deleteArtifactByAppKey(apiKey,ArtifactService.lastVersionBranchName, ArtifactService.lastVersionName,artifactName);
  }

  @ApiMethod(method: 'GET', path: 'app/{appId}/icon')
  Future<MediaMessage> getApplicationIcon(String appId) async {
    var application = await appService.ApplicationService.applicationByAppId(appId);

    String base64icon = application.base64IconData;
    if (base64icon != null) {
      print("length ${base64icon.length}");
      var dataTypeIndex = base64icon.indexOf('data:');
      var dataBytesIndex = base64icon.indexOf(';base64,');
      var endDataTypeIndex = dataBytesIndex;
      if (dataTypeIndex != -1 && dataBytesIndex != -1) {
        dataTypeIndex += 5;
        dataBytesIndex += 8;

        try {
          var imageType = base64icon.substring(dataTypeIndex, endDataTypeIndex);
          var base64 = base64icon.substring(dataBytesIndex);
          var result = new MediaMessage();
          result.contentType = imageType;
          result.bytes = CryptoUtils.base64StringToBytes(base64);
          return result;
        } catch (e) {
          throw new RpcError(500, "APPLICATION_ERROR","Invalid icon format");
        }
      }
    }

    //var imageTypeindex = application.bas
    // return 'data:image/jpeg;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==';
    /*'data:image/jpeg;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg=='*/

    throw new NotFoundError("Icon not found");
  }

  @ApiMethod(method: 'GET', path: 'artifacts/{idArtifact}/ios_plist')
  Future<MediaMessage> getArtifactDescriptor(String idArtifact,{String token}) async{

  }

  @ApiMethod(method: 'GET', path: 'artifacts/{idArtifact}/file')
  Future<MediaMessage> deleteArtifact(String idArtifact,{String token}) async{

  }
}
