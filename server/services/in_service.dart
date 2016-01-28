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


final String PLIST_CONTENT_TYPE ='application/plist';
final String TEMPLATE_IPA_URL_KEY='@URL_TO_IPA@';
final String TEMPLATE_BUNDLE_ID_KEY='@BUNDLE_IDENTIFIER@';
final String TEMPLATE_BUNDLE_VERSION_KEY='@BUNDLE_VERSION@';
final String TEMPLATE_APP_NAME_KEY='@APPLICATION_NAME@';
final String TAG_BUNDLE_ID = 'MDT_IOS_BUNDLE_ID';
final String TAG_BUNDLE_VERSION = 'MDT_IOS_BUNDLE_VERSION';

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
      createdArtifact.filename = mediaMsg.metadata["filename"];
      var tempFile = await new File("$tempDir/${createdArtifact.filename}").create(recursive:true);
      await tempFile.writeAsBytes(mediaMsg.bytes,flush:true);
      createdArtifact.size = tempFile.lengthSync();

      createdArtifact.contentType = mediaMsg.contentType;
      await mgrs.addFileToArtifact(tempFile,createdArtifact,mgrs.defaultStorage);
    }catch(e){
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
   throw new NotFoundError("Icon not found");
  }

  @ApiMethod(method: 'GET', path: 'artifacts/{idArtifact}/ios_plist')
  Future<MediaMessage> getArtifactDescriptor(String idArtifact,{String token}) async{
    try {
      var artifact = await mgrs.findArtifact(idArtifact);
      if (artifact == null){
        throw new NotFoundError();
      }
      var result = new MediaMessage();
      result.contentType='application/plist';
      var plistString = plistTemplate;
      plistString = plistString.replaceFirst(new RegExp(TEMPLATE_IPA_URL_KEY,multiLine: true),'/api/in/v1/artifacts/$idArtifact/file');
      var application = await artifact.application.getMeFromDb();
      plistString =plistString.replaceFirst(new RegExp(TEMPLATE_APP_NAME_KEY,multiLine: true),artifact.application.name);
      if (artifact.metaDataTags != null){
        var tags = JSON.decode(artifact.metaDataTags);
        plistString.replaceFirst(new RegExp(TEMPLATE_BUNDLE_ID_KEY,multiLine: true),tags[TAG_BUNDLE_ID]);
        plistString.replaceFirst(new RegExp(TEMPLATE_BUNDLE_VERSION_KEY,multiLine: true),tags[TAG_BUNDLE_VERSION]);
      }
      result.bytes = UTF8.encode(plistString);
      return result;
    }
    catch(e){
      throw new InternalServerError("Error ${e.toString()}");
    }
  }

  final String plistTemplate = r'''
  <?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/
PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>items</key>
        <array>
                <dict>
                        <key>assets</key>
                        <array>
                                <dict>
                                        <key>kind</key>
                                        <string>software-package</string>
                                        <key>url</key>
                                        <string>@URL_TO_IPA@</string>
                                </dict>
                        </array>
                        <key>metadata</key>
                        <dict>
                                <key>bundle-identifier</key>
                                <string>@BUNDLE_IDENTIFIER@</string>
                                <key>bundle-version</key>
                                <string>@BUNDLE_VERSION@</string>
                                <key>kind</key>
                                <string>software</string>
                                <key>title</key>
                                <string>@APPLICATION_NAME@</string>
                        </dict>
                </dict>
        </array>
</dict>
</plist>
''';

/*
  @ApiMethod(method: 'GET', path: 'artifacts/{idArtifact}/file')
  Future<MediaMessage> getArtifactFile(String idArtifact,{String token}) async{
      var artifact = await mgrs.findArtifact(idArtifact);
      if (artifact == null){
        throw new NotFoundError();
      }
      try {
        Stream stream = await mgrs.streamFromArtifact(artifact, mgrs.defaultStorage);
        var result = new MediaMessage();
        result.bytesStream = stream;
        result.contentType = artifact.contentType;
        return result;
      }catch(e){
        print("$e");
      }
  }*/

}
