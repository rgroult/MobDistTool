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
import '../analyzers/artifact_analyzer.dart' as analyzer;
import '../config/config.dart' as config;

final String PLIST_CONTENT_TYPE = 'application/plist';
final String TEMPLATE_IPA_URL_KEY = '@URL_TO_IPA@';
final String TEMPLATE_BUNDLE_ID_KEY = '@BUNDLE_IDENTIFIER@';
final String TEMPLATE_BUNDLE_VERSION_KEY = '@BUNDLE_VERSION@';
final String TEMPLATE_APP_NAME_KEY = '@APPLICATION_NAME@';

@ApiClass(name: 'in', version: 'v1')
class InService {
  @ApiMethod(
      method: 'POST',
      path: 'artifacts/{apiKey}/{branch}/{version}/{artifactName}')
  Future<Response> addArtifactByAppKey(String apiKey, String branch,
      String version, String artifactName, ArtifactMsg artifactsMsg) async {
    var application = await mgrs.findApplicationByApiKey(apiKey);
    var mediaMsg = artifactsMsg.artifactFile;
    if (application == null) {
      throw new NotFoundError('Application not found');
    }

    //find existng artifact
    var existingArtifact = await mgrs.findArtifactByInfos(
        application, branch, version, artifactName);
    if (existingArtifact != null) {
      throw new RpcError(
          400, 'ARTIFACT_ERROR', 'artifact exist with provided infos');
    }
    var createdArtifact = null;
    try {
      //Create temp file
      var tempDir = Directory.systemTemp.createTempSync("art").path;
      var filename = mediaMsg.metadata["filename"];

      var tempFile =
      await new File("$tempDir/${filename}").create(recursive: true);
      await tempFile.writeAsBytes(mediaMsg.bytes, flush: true);

      //check artifact validity : ipa or apk
      var tags = await analyzer.analyzeAndExtractArtifactInfos(
          tempFile, application.platform);

      var parsedTags = null;
      if (artifactsMsg.jsonTags != null) {
        parsedTags =  JSON.decode(artifactsMsg.jsonTags);//parseTags(artifactsMsg.jsonTags);
      }
      if (parsedTags != null) {
        //Add to tags provided by analyzer
        tags.addAll(parsedTags);
      }
      //create artifact
      createdArtifact = await mgrs.createArtifact(
          application, artifactName, version, branch,
          sortIdentifier: artifactsMsg.sortIdentifier, tags: JSON.encode(tags));
      createdArtifact.filename = filename;
      createdArtifact.size = tempFile.lengthSync();

      createdArtifact.contentType = mediaMsg.contentType;
      await mgrs.addFileToArtifact(
          tempFile, createdArtifact, mgrs.defaultStorage);
    } catch (e) {
      //delete created artifact
      if (createdArtifact != null){
        await mgrs.deleteArtifact(createdArtifact, mgrs.defaultStorage);
      }

      throw new RpcError(
          500, 'ARTIFACT_ERROR', 'Unable to add artifact: ${e.message}');
      // ..errors.add(new RpcErrorDetail(reason: e.message));
    }

    var jsonResponse = toJson(createdArtifact, isAdmin: true);
    return new Response(200, toJson(createdArtifact, isAdmin: true));
  }

  @ApiMethod(
      method: 'DELETE',
      path: 'artifacts/{apiKey}/{branch}/{version}/{artifactName}')
  Future<Response> deleteArtifactByAppKey(
      String apiKey, String branch, String version, String artifactName) async {
    var application = await mgrs.findApplicationByApiKey(apiKey);
    if (application == null) {
      throw new NotFoundError('Application not found');
    }
    var existingArtifact =
    await mgrs.findArtifactByInfos(app, branch, version, artifactName);
    if (existingArtifact != null) {
      await mgrs.deleteArtifact(existingArtifact, mgrs.defaultStorage);
    }
    return new OKResponse();
  }

  @ApiMethod(method: 'POST', path: 'artifacts/{apiKey}/last/{artifactName}')
  Future<Response> addLastArtifactByAppKey(
      String apiKey, String artifactName, ArtifactMsg artifactsMsg) async {
    return addArtifactByAppKey(apiKey, ArtifactService.lastVersionBranchName,
        ArtifactService.lastVersionName, artifactName, artifactsMsg);
  }

  @ApiMethod(method: 'DELETE', path: 'artifacts/{apiKey}/last/{artifactName}')
  Future<Response> deleteLastArtifactByAppKey(
      String apiKey, String artifactName) async {
    return deleteArtifactByAppKey(apiKey, ArtifactService.lastVersionBranchName,
        ArtifactService.lastVersionName, artifactName);
  }

  @ApiMethod(method: 'GET', path: 'app/{appId}/icon')
  Future<MediaMessage> getApplicationIcon(String appId) async {
    var application =
    await appService.ApplicationService.applicationByAppId(appId);

    String base64icon = application.base64IconData;
    if (base64icon != null) {
      //print("length ${base64icon.length}");
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
          result.updated = application.getProperty('modifiedAt');
          return result;
        } catch (e) {
          throw new RpcError(500, "APPLICATION_ERROR", "Invalid icon format");
        }
      }
    }
    throw new NotFoundError("Icon not found");
  }

  @ApiMethod(method: 'GET', path: 'artifacts/{idArtifact}/ios_plist')
  Future<MediaMessage> getArtifactDescriptor(String idArtifact,
      {String token}) async {
    try {
      var artifact = await mgrs.findArtifact(idArtifact);
      if (artifact == null) {
        throw new NotFoundError();
      }
      var result = new MediaMessage();
      result.contentType = 'application/plist';
      var plistString = plistTemplate;
      var fileDownloadUrl = '/api/in/v1/artifacts/$idArtifact/file';
      if (config.currentLoadedConfig[config.MDT_SERVER_URL] != null){
        fileDownloadUrl = '${config.currentLoadedConfig[config.MDT_SERVER_URL]}${fileDownloadUrl}';
      }
      plistString = plistString.replaceFirst(new RegExp(TEMPLATE_IPA_URL_KEY, multiLine: true), fileDownloadUrl);
      //    '/api/in/v1/artifacts/$idArtifact/file');
      var application = await artifact.application.getMeFromDb();
      plistString = plistString.replaceFirst( new RegExp(TEMPLATE_APP_NAME_KEY, multiLine: true), artifact.application.name);
      if (artifact.metaDataTags != null) {
        var tags = JSON.decode(artifact.metaDataTags);
        plistString = plistString.replaceFirst(new RegExp(TEMPLATE_BUNDLE_ID_KEY, multiLine: true), tags["CFBundleIdentifier"]);
        plistString = plistString.replaceFirst(new RegExp(TEMPLATE_BUNDLE_VERSION_KEY, multiLine: true),tags["CFBundleVersion"]);
      }
      result.bytes = UTF8.encode(plistString);
      return result;
    } catch (e) {
      throw new RpcError(500, 'ARTIFACT_ERROR', "Error ${e.toString()}");
    }
  }

  final String plistTemplate = r'''
  <?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
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
}
