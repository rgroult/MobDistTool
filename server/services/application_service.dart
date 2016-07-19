// Copyright (c) 2016, the Mobile App Distribution Tool project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:rpc/rpc.dart';
import 'package:crypto/crypto.dart';
import '../managers/managers.dart' as mgrs;
import 'user_service.dart' as userService;
import 'artifact_service.dart' as artifactMgr;
import 'model.dart';
import '../model/model.dart';
import 'json_convertor.dart';
import '../utils/utils.dart';
import '../activity/activity_tracking.dart';

@ApiClass(name: 'applications' , version: 'v1')
class ApplicationService {
  var supportedPlatform = ['android','ios'];

  String checkSupportedPlatform(String platform){
    var lowerCasePlatform = platform.toLowerCase();
    if (supportedPlatform.contains(lowerCasePlatform)){
      return lowerCasePlatform;
    }
    throw new RpcError(400, 'APPLICATION_ERROR', 'Unsuported platform, only ${supportedPlatform.toString()} supported');
    //throw new RpcError(400, 'BadRequest', 'Unsuported platform, only ${supportedPlatform.toString()} supported');
  }

  static Future<MDTApplication> applicationByAppId(String appId) async {
    var application = await mgrs.findApplicationByUuid(appId);
    if (application == null){
      throw new NotFoundError('Application not found');
    }
    return application;
  }

  Future<MDTApplication> findApplicationByAppId(String appId) async {
    return ApplicationService.applicationByAppId(appId);
  }

  @ApiMethod(method: 'POST', path: 'create')
  Future<Response> createApplication(CreateApplication createMsg) async{
    var platform = checkSupportedPlatform(createMsg.platform);
    var currentuser = userService.currentAuthenticatedUser();
    try {
      var appCreated = await mgrs.createApplication(createMsg.name,platform,description:createMsg.description,adminUser:currentuser,base64Icon:createMsg.base64IconData,maxVersionCheckEnabled:createMsg.enableMaxVersionCheck);
      var response = await toJson(appCreated, isAdmin:true);
      trackCreateApp(appCreated,currentuser);
      return new Response(200, response);
    } on StateError catch (e) {
      //var error = e;
      //  throw new BadRequestError( e.message);
      throw new RpcError(400, 'APPLICATION_ERROR',  e.message);
      //  throw new RpcError(400, 'InvalidRequest', 'Unable to create app')
      //  ..errors.add(new RpcErrorDetail(reason: e.message));
    }catch(e,stack){
      manageExceptions(e,stack);
    }
  }

  @ApiMethod(method: 'GET', path: 'search')
  Future<ResponseList> allApplications({String platform}) async{
    try {
      var _platform = platform;
      if (_platform != null) {
        _platform = checkSupportedPlatform(_platform);
      }
      var allApps = await mgrs.allApplications(platform: _platform);
      var currentuser = userService.currentAuthenticatedUser();
      var responseJson = await listToJson(
          allApps, isAdmin: currentuser.isSystemAdmin);
      return new ResponseList(200, responseJson);
    }catch(error,stack){
      manageExceptions(error,stack);
    }
  }

  @ApiMethod(method: 'GET', path: 'app/{appId}')
  Future<Response> applicationDetail(String appId) async{
    try{
      var application = await findApplicationByAppId(appId);
      application = await application.fetchLinks();
      var currentuser = userService.currentAuthenticatedUser();
      return new Response(200, await toJson(application,isAdmin:mgrs.isAdminForApp(application,currentuser)));
    }catch(error,stack){
      manageExceptions(error,stack);
    }
  }

  @ApiMethod(method: 'PUT', path: 'app/{appId}')
  Future<Response> updateApplication(String appId, UpdateApplication updateMsg) async{
    var application = await findApplicationByAppId(appId);
    var currentuser = userService.currentAuthenticatedUser();
    if (mgrs.isAdminForApp(application,currentuser) == false){
      throw new NotApplicationAdministrator();
    }
    try {
      application = await mgrs.updateApplication(application,name:updateMsg.name,platform:updateMsg.platform,description:updateMsg.description,base64Icon:updateMsg.base64IconData,maxVersionCheckEnabled:updateMsg.enableMaxVersionCheck);
      return new Response(200, await toJson(application,isAdmin:true));
    }on StateError catch (e) {
      //var error = e;
      //  throw new BadRequestError( e.message);
      throw new RpcError(500, 'APPLICATION_ERROR',  e.message);
      /* throw new RpcError(500, 'Update Error', 'Unable to update app')
        ..errors.add(new RpcErrorDetail(reason: e.message));*/
    }catch(error,stack){
      manageExceptions(error,stack);
    }
  }

  @ApiMethod(method: 'DELETE', path: 'app/{appId}')
  Future<Response> deleteApplication(String appId) async {
    try {
      var application = await findApplicationByAppId(appId);
      var currentuser = userService.currentAuthenticatedUser();
      if (mgrs.isAdminForApp(application, currentuser) == false) {
        throw new NotApplicationAdministrator();
      }
      trackDeleteApp(application,currentuser);
      await mgrs.deleteApplicationByObject(application);
      return new OKResponse();
    } catch(error,stack){
      manageExceptions(error,stack);
    }
  }

  @ApiMethod(method: 'PUT', path: 'app/{appId}/adminUser')
  Future<Response> addAdminUserApplication(String appId,AddAdminUserMessage msg) async {
    try{
      var adminEmail = msg.email;
      if (adminEmail == null){
        throw new RpcError(400, 'InvalidRequest', 'new admin user email not found');
      }
      var application = await findApplicationByAppId(appId);
      var currentuser = userService.currentAuthenticatedUser();
      if (mgrs.isAdminForApp(application,currentuser) == false){
        throw new NotApplicationAdministrator();
      }
      //find user to add
      var user = await mgrs.findUserByEmail(adminEmail);
      if (user == null){
        throw new RpcError(400, 'APPLICATION_ERROR',  'user not found for email $adminEmail');
        // throw new RpcError(400, 'InvalidRequest', 'user not found for email $adminEmail');
      }
      await mgrs.addAdminApplication(application,user);
      return new OKResponse();
    } catch(error,stack){
      manageExceptions(error,stack);
    }
  }

  @ApiMethod(method: 'DELETE', path: 'app/{appId}/adminUser')
  Future<Response> deleteAdminUserApplication(String appId,{String adminEmail}) async {
    try{
      if (adminEmail == null){
        throw new RpcError(400, 'APPLICATION_ERROR',  'admin user email not found');
        //throw new RpcError(400, 'InvalidRequest', 'admin user email not found');
      }
      var application = await findApplicationByAppId(appId);
      var currentuser = userService.currentAuthenticatedUser();
      if (mgrs.isAdminForApp(application,currentuser) == false){
        throw new NotApplicationAdministrator();
      }
      //find user to add
      var user = await mgrs.findUserByEmail(adminEmail);
      if (user == null){
        throw new RpcError(400, 'APPLICATION_ERROR',  'user not found for email $adminEmail');
        //throw new RpcError(400, 'InvalidRequest', 'user not found for email $adminEmail');
      }
      if (application.adminUsers.contains(user) == false){
        throw new RpcError(400, 'APPLICATION_ERROR',  'user with email $adminEmail not a admin user for this application');
      }
      if (application.adminUsers.length == 1){
        throw new RpcError(500, 'APPLICATION_ERROR',  'Delete of last administrator forbidden');
      }
      await mgrs.removeAdminApplication(application,user);
      return new OKResponse();
    } catch(error,stack){
      manageExceptions(error,stack);
    }
  }

  @ApiMethod(method: 'GET', path: 'app/{appId}/versions')
  Future<ResponseList> getApplicationVersions(String appId,{int pageIndex, int limitPerPage,String branch}) async {
    try{
      var application = await findApplicationByAppId(appId);
      var allVersions = await mgrs.searchArtifacts(application,pageIndex:pageIndex, limitPerPage:limitPerPage,branch:branch,branchToExclude:artifactMgr.ArtifactService.lastVersionBranchName);
      var responseJson = await listToJson(allVersions,isAdmin:true);
      return new ResponseList(200, responseJson);
      // return new ResponseList(200, listToJson(allVersions));
    } catch(error,stack){
      manageExceptions(error,stack);
    }
  }

  //..add('api/applications/v1/app/{appId}/maxversion',null,apiHandler,exactMatch: false);
  @ApiMethod(method: 'GET', path: 'app/{appId}/maxversion/{name}')
  Future<Response> getApplicationMaxVersion(String appId,String name,{String ts,String hash,String branch}) async {
    try {
      if (ts == null || hash == null){
        throw new BadRequestError();
      }
      var date = new DateTime.now().millisecondsSinceEpoch;
      var timestamp = int.parse(ts);

      if ((date-timestamp).abs()> 30000){ //30 secs
        throw new RpcError(401,"ARTIFACT_ERROR","Access expired");
      }
      var application = await findApplicationByAppId(appId);

      if (application.maxVersionSecretKey == null || application.maxVersionSecretKey.isEmpty ){
        throw new RpcError(401,"ARTIFACT_ERROR","Application disabled");
      }
      //check hash
      branch= branch!= null ? branch : "";
      var stringToHash = "ts=$ts&branch=$branch&hash=${application.maxVersionSecretKey}";
      var generatedHash = generateHash(stringToHash);
      if (generatedHash != hash){
        throw new RpcError(401,"ARTIFACT_ERROR","Invalid signature");
      }

      String selectedBranch = artifactMgr.ArtifactService.lastVersionBranchName;
      if(branch.length > 0){
        selectedBranch = branch;
      }
      var artifact = await mgrs.searchMaxArtifactVersion(application,selectedBranch,name);
      var jsonResult = {};
      if (artifact == null) {
        throw new NotFoundError();
      }
      if (branch != null){
          jsonResult["branch"] = branch;
      }

      jsonResult["version"] =  artifact.version;
      jsonResult["name"] =  artifact.name;

      var downloadInfo =  await artifactMgr.ArtifactService.downloadInfo(artifact,null);
      if (downloadInfo == null){
        throw new NotFoundError();
      }

      jsonResult["downloadInfo"] =downloadInfo.toJson();


      return new Response(200, jsonResult);

    } catch(error,stack){
      print("$error");
      manageExceptions(error,stack);
    }
  }

  @ApiMethod(method: 'GET', path: 'app/{appId}/icon')
  Future<MediaMessage> getApplicationIcon(String appId) async {
    try{
      var application = await findApplicationByAppId(appId);

      String base64icon = application.base64IconData;
      if (base64icon != null) {}
      var dataTypeIndex = base64icon.indexOf('data:');
      var dataBytesIndex = base64icon.indexOf(';base64,');
      var endDataTypeIndex= dataBytesIndex;
      if (dataTypeIndex != -1 && dataBytesIndex != -1) {
        dataTypeIndex += 5;
        dataBytesIndex += 8;

        var imageType = base64icon.substring(dataBytesIndex,endDataTypeIndex);
        var base64 = base64icon.substring(dataTypeIndex);
        var result = new MediaMessage();
        result.contentType = imageType;
        result.bytes = CryptoUtils.base64StringToBytes(base64);
        return result;
      }
      throw new NotFoundError("Icon not found");
    } catch(error,stack){
      manageExceptions(error,stack);
    }
  }

  @ApiMethod(method: 'GET', path: 'app/{appId}/versions/last')
  Future<ResponseList> getApplicationLastVersions(String appId) async {
    try{
      var application = await findApplicationByAppId(appId);
      var allVersions = await mgrs.searchArtifacts(application, branch:artifactMgr.ArtifactService.lastVersionBranchName);
      var responseJson = await listToJson(allVersions);
      return new ResponseList(200, responseJson);
    } catch(error,stack){
      manageExceptions(error,stack);
    }
  }
}