// Copyright (c) 2016, the Mobile App Distribution Tool project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:async';
import 'package:rpc/rpc.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:jwt/json_web_token.dart';
import '../managers/managers.dart' as mgrs;
import 'application_service.dart' as appService;
import 'artifact_service.dart';
import 'model.dart';
import 'json_convertor.dart';
import '../analyzers/artifact_analyzer.dart' as analyzer;
import '../config/config.dart' as config;
import '../utils/utils.dart';
import '../activity/activity_tracking.dart';

final String PLIST_CONTENT_TYPE = 'application/plist';
final String TEMPLATE_IPA_URL_KEY = '@URL_TO_IPA@';
final String TEMPLATE_BUNDLE_ID_KEY = '@BUNDLE_IDENTIFIER@';
final String TEMPLATE_BUNDLE_VERSION_KEY = '@BUNDLE_VERSION@';
final String TEMPLATE_APP_NAME_KEY = '@APPLICATION_NAME@';

final String IPA_CONTENT_TYPE = 'application/octet-stream ipa';
final String APK_CONTENT_TYPE = 'application/vnd.android.package-archive';

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

@ApiClass(name: 'in', version: 'v1')
class InService {
  JsonWebTokenCodec jsonWebToken;
  InService(){
    jsonWebToken = new JsonWebTokenCodec(secret: config.currentLoadedConfig[config.MDT_TOKEN_SECRET]);
  }

  @ApiMethod(
      method: 'GET',
      path: 'artifacts/{apiKey}/deploy')
  Future<MediaMessage> deployScript(String apiKey) async {
    //check if application exist
    /*var application = await mgrs.findApplicationByApiKey(apiKey);
    if (application == null) {
      throw new NotFoundError('Application not found');
    }*/

    var scriptCcontent = await new File('scripts/deploy.py').readAsString();
    //replace values
    scriptCcontent= scriptCcontent.replaceFirst(new RegExp("<REPLACE_WITH_SERVER>", multiLine: true), config.currentLoadedConfig[config.MDT_SERVER_URL]);
    scriptCcontent= scriptCcontent.replaceFirst(new RegExp("<REPLACE_WITH_API_KEY>", multiLine: true), apiKey);

    var script  = new MediaMessage()
      ..bytes = scriptCcontent.codeUnits;
    return script;
  }

  @ApiMethod(
      method: 'POST',
      path: 'artifacts/{apiKey}/{_branch}/{_version}/{_artifactName}')
  Future<Response> addArtifactByAppKey(String apiKey, String _branch,
      String _version, String _artifactName, ArtifactMsg artifactsMsg) async {
    try{
      var branch = Uri.decodeComponent(_branch);
      var version = Uri.decodeComponent(_version);
      var artifactName = Uri.decodeComponent(_artifactName);
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

        //set content type, related to application platfom
        if (application.platform.toUpperCase() == "IOS"){
          createdArtifact.contentType = IPA_CONTENT_TYPE;
        }else if (application.platform.toUpperCase() == "ANDROID"){
          createdArtifact.contentType = APK_CONTENT_TYPE;
        }

        await mgrs.addFileToArtifact(
            tempFile, createdArtifact, mgrs.defaultStorage);
      } catch (e) {
        //delete created artifact
        if (createdArtifact != null){
          await mgrs.deleteArtifact(createdArtifact, mgrs.defaultStorage);
        }

        throw new RpcError(
            400, 'ARTIFACT_ERROR', 'Unable to add artifact: ${e.message}');
        // ..errors.add(new RpcErrorDetail(reason: e.message));
      }

      trackUploadArtifact(application,createdArtifact);
      //var jsonResponse = toJson(createdArtifact, isAdmin: true);
      return new Response(200, await toJson(createdArtifact, isAdmin: true));
    }catch(e,stack){
      manageExceptions(e,stack);
    }
  }

  @ApiMethod(
      method: 'DELETE',
      path: 'artifacts/{apiKey}/{_branch}/{_version}/{_artifactName}')
  Future<Response> deleteArtifactByAppKey(
      String apiKey, String _branch, String _version, String _artifactName) async {
    try{
      var branch = Uri.decodeComponent(_branch);
      var version = Uri.decodeComponent(_version);
      var artifactName = Uri.decodeComponent(_artifactName);
      var application = await mgrs.findApplicationByApiKey(apiKey);
      if (application == null) {
        throw new NotFoundError('Application not found');
      }
      var existingArtifact =
      await mgrs.findArtifactByInfos(application, branch, version, artifactName);

      if (existingArtifact != null) {
        trackDeleteArtifact(application,existingArtifact);
        await mgrs.deleteArtifact(existingArtifact, mgrs.defaultStorage);
      }
      return new OKResponse();
    }catch(e,stack){
      manageExceptions(e,stack);
    }
  }

  @ApiMethod(method: 'POST', path: 'artifacts/{apiKey}/last/{_artifactName}')
  Future<Response> addLastArtifactByAppKey(
      String apiKey, String _artifactName, ArtifactMsg artifactsMsg) async {
    try{
      var artifactName = Uri.decodeComponent(_artifactName);
      return addArtifactByAppKey(apiKey, ArtifactService.lastVersionBranchName,
          ArtifactService.lastVersionName, artifactName, artifactsMsg);
    }catch(e,stack){
      manageExceptions(e,stack);
    }
  }

  @ApiMethod(method: 'DELETE', path: 'artifacts/{apiKey}/last/{_artifactName}')
  Future<Response> deleteLastArtifactByAppKey(
      String apiKey, String _artifactName) async {
    try{
      var artifactName = Uri.decodeComponent(_artifactName);
      return deleteArtifactByAppKey(apiKey, ArtifactService.lastVersionBranchName,
          ArtifactService.lastVersionName, artifactName);
    }catch(e,stack){
      manageExceptions(e,stack);
    }
  }

  @ApiMethod(method: 'GET', path: 'app/{appId}/icon')
  Future<MediaMessage> getApplicationIcon(String appId) async {
    try{
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
    }catch(e,stack){
      manageExceptions(e,stack);
    }
  }

  @ApiMethod(method: 'GET', path: 'artifacts/{idArtifact}/ios_plist')
  Future<MediaMessage> getArtifactDescriptor(String idArtifact, {String token}) async {
    try {
      var artifact = await mgrs.findArtifact(idArtifact);
      if (artifact == null) {
        throw new NotFoundError();
      }
      var result = new MediaMessage();
      result.contentType = 'application/plist';
      var plistString = plistTemplate;
      var fileDownloadUrl = '/api/in/v1/artifacts/$idArtifact/file?token=$token';
      if (config.currentLoadedConfig[config.MDT_SERVER_URL] != null){
        fileDownloadUrl = '${config.currentLoadedConfig[config.MDT_SERVER_URL]}${fileDownloadUrl}';
      }
      plistString = plistString.replaceFirst(new RegExp(TEMPLATE_IPA_URL_KEY, multiLine: true), fileDownloadUrl);
      //    '/api/in/v1/artifacts/$idArtifact/file');
      await artifact.application.getMeFromDb();
      plistString = plistString.replaceFirst( new RegExp(TEMPLATE_APP_NAME_KEY, multiLine: true), artifact.application.name);
      if (artifact.metaDataTags != null) {
        var tags = JSON.decode(artifact.metaDataTags);
        plistString = plistString.replaceFirst(new RegExp(TEMPLATE_BUNDLE_ID_KEY, multiLine: true), tags["CFBundleIdentifier"]);
        plistString = plistString.replaceFirst(new RegExp(TEMPLATE_BUNDLE_VERSION_KEY, multiLine: true),tags["CFBundleVersion"]);
      }
      result.bytes = UTF8.encode(plistString);
      return result;
    }catch(e,stack){
      manageExceptions(e,stack);
    }
  }

  @ApiMethod(method: 'POST', path: 'activation')
  Future<Response> userActivation(ActivationMessage message) async {
    try{
      var activationToken = message.activationToken;
      print("Activation token $activationToken");
      if (!jsonWebToken.isValid(activationToken)){
        throw new RpcError(400, 'ACTIVATION_ERROR', "Invalid token");
      }
      Map tokenInfo = jsonWebToken.decode(activationToken);
      var userEmail= tokenInfo["user"];
      var token= tokenInfo["token"];
      //retrieve user
      var user = await mgrs.findUserByEmail(userEmail);
      if (user == null){
        throw new NotFoundError();
      }
      if (user.isActivated){
        throw new RpcError(400, 'ACTIVATION_ERROR', "Bad activation state");
      }
      if (user.activationToken == token){
        //Activate user
        user.isActivated = true;
        user.activationToken = null;
        await user.save();
      }else {
        throw new RpcError(400, 'ACTIVATION_ERROR', "Invalid token");
      }

      return new OKResponse();
    }catch(e,stack){
      manageExceptions(e,stack);
    }
  }
}
