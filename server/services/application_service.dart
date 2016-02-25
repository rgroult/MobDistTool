// Copyright (c) 2016, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:async';
import 'package:rpc/rpc.dart';
import 'package:crypto/crypto.dart';
import '../managers/managers.dart' as mgrs;
import 'user_service.dart' as userService;
import 'artifact_service.dart' as artifactMgr;
import 'model.dart';
import '../model/model.dart';
import 'json_convertor.dart';

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
      var appCreated = await mgrs.createApplication(createMsg.name,platform,description:createMsg.description,adminUser:currentuser,base64Icon:createMsg.base64IconData);
      var response = toJson(appCreated, isAdmin:true);
      return new Response(200, response);
    } on StateError catch (e) {
      var error = e;
      //  throw new BadRequestError( e.message);
      throw new RpcError(400, 'APPLICATION_ERROR',  e.message);
    //  throw new RpcError(400, 'InvalidRequest', 'Unable to create app')
      //  ..errors.add(new RpcErrorDetail(reason: e.message));
    }
  }

  @ApiMethod(method: 'GET', path: 'search')
  Future<ResponseList> allApplications({String platform}) async{
    var _platform = platform;
    if (_platform != null){
      _platform = checkSupportedPlatform(_platform);
    }
    var allApps = await mgrs.allApplications(platform:_platform);
    var currentuser = userService.currentAuthenticatedUser();
    var responseJson = listToJson(allApps,isAdmin:currentuser.isSystemAdmin);
    return new ResponseList(200, responseJson);
  }

  @ApiMethod(method: 'GET', path: 'app/{appId}')
  Future<Response> applicationDetail(String appId) async{
    var application = await findApplicationByAppId(appId);
    var currentuser = userService.currentAuthenticatedUser();
    return new Response(200, toJson(application,isAdmin:mgrs.isAdminForApp(application,currentuser)));
  }

  @ApiMethod(method: 'PUT', path: 'app/{appId}')
  Future<Response> updateApplication(String appId, UpdateApplication updateMsg) async{
    var application = await findApplicationByAppId(appId);
    var currentuser = userService.currentAuthenticatedUser();
    if (mgrs.isAdminForApp(application,currentuser) == false){
      throw new NotApplicationAdministrator();
    }
    try {
      application = await mgrs.updateApplication(application,name:updateMsg.name,platform:updateMsg.platform,description:updateMsg.description,base64Icon:updateMsg.base64IconData);
      return new Response(200, toJson(application,isAdmin:true));
    }on StateError catch (e) {
      var error = e;
      //  throw new BadRequestError( e.message);
      throw new RpcError(500, 'APPLICATION_ERROR',  e.message);
     /* throw new RpcError(500, 'Update Error', 'Unable to update app')
        ..errors.add(new RpcErrorDetail(reason: e.message));*/
    }
  }

  @ApiMethod(method: 'DELETE', path: 'app/{appId}')
  Future<Response> deleteApplication(String appId) async {
    var application = await findApplicationByAppId(appId);
    var currentuser = userService.currentAuthenticatedUser();
    if (mgrs.isAdminForApp(application,currentuser) == false){
      throw new NotApplicationAdministrator();
    }
    await mgrs.deleteApplicationByObject(application);
    return new OKResponse();
  }

  @ApiMethod(method: 'PUT', path: 'app/{appId}/adminUser')
  Future<Response> addAdminUserApplication(String appId,AddAdminUserMessage msg) async {
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
  }

  @ApiMethod(method: 'DELETE', path: 'app/{appId}/adminUser')
  Future<Response> deleteAdminUserApplication(String appId,{String adminEmail}) async {
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
    if (application.adminUsers.length == 1){
      throw new RpcError(500, 'APPLICATION_ERROR',  'Delete of last administrator forbidden');
    }
    await mgrs.removeAdminApplication(application,user);
    return new OKResponse();
  }

  @ApiMethod(method: 'GET', path: 'app/{appId}/versions')
  Future<ResponseList> getApplicationVersions(String appId,{int pageIndex, int limitPerPage,String branch}) async {
    var application = await findApplicationByAppId(appId);
    var allVersions = await mgrs.searchArtifacts(application,pageIndex:pageIndex, limitPerPage:limitPerPage,branch:branch,branchToExclude:artifactMgr.ArtifactService.lastVersionBranchName);
    var responseJson = listToJson(allVersions,isAdmin:true);
    return new ResponseList(200, responseJson);
   // return new ResponseList(200, listToJson(allVersions));
  }

  @ApiMethod(method: 'GET', path: 'app/{appId}/icon')
  Future<MediaMessage> getApplicationIcon(String appId) async {
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
  }

  @ApiMethod(method: 'GET', path: 'app/{appId}/versions/last')
  Future<ResponseList> getApplicationLastVersions(String appId) async {
    var application = await findApplicationByAppId(appId);
    var allVersions = await mgrs.searchArtifacts(application, branch:artifactMgr.ArtifactService.lastVersionBranchName);
    var responseJson = listToJson(allVersions);
    return new ResponseList(200, responseJson);
    // return new ResponseList(200, listToJson(allVersions));
  }
}



/*
 app.get('/admin/applications', applicationController.listAllApplications)

	//applications routes
    app.post('/applications', passport.authenticate('bearer', { session: false }), applicationController.createApplication)
    app.get('/applications', passport.authenticate('bearer', { session: false }), applicationController.listAllApplicationsForUser)

    app.put('/applications/:idapp', passport.authenticate('bearer', { session: false }), applicationController.canUpdateApplication,applicationController.updateById)
    app.get('/applications/:idapp', passport.authenticate('bearer', { session: false }), applicationController.canAccessApplication,applicationController.findById)
    app.delete('/applications/:idapp', passport.authenticate('bearer', { session: false }), applicationController.canUpdateApplication,applicationController.deleteById)
    //members management
    app.put('/applications/:idapp/adminmembers/:useremail',passport.authenticate('bearer', { session: false }), applicationController.canUpdateApplication,applicationController.addAdminMember)
    app.delete('/applications/:idapp/adminmembers/:useremail',passport.authenticate('bearer', { session: false }), applicationController.canUpdateApplication,applicationController.removeAdminMember)
    app.put('/applications/:idapp/members/:useremail',passport.authenticate('bearer', { session: false }), applicationController.canUpdateApplication,applicationController.addMember)
    app.delete('/applications/:idapp/members/:useremail',passport.authenticate('bearer', { session: false }), applicationController.canUpdateApplication,applicationController.removeMember)
    app.put('/applications/:idapp/extmembers/:useremail',passport.authenticate('bearer', { session: false }), applicationController.canUpdateApplication,applicationController.addExtMember)
    app.delete('/applications/:idapp/extmembers/:useremail',passport.authenticate('bearer', { session: false }), applicationController.canUpdateApplication,applicationController.removeExtMember)
    //versions
    app.get('/applications/:idapp/versions/:version', passport.authenticate('bearer', { session: false }), applicationController.canAccessApplication, applicationController.versionInformations)
    app.get('/applications/:idapp/versions', passport.authenticate('bearer', { session: false }), app

 */