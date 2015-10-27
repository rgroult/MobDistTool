import 'dart:io';
import 'dart:async';
import 'package:rpc/rpc.dart';
import '../managers/managers.dart' as mgrs;
import 'user_service.dart' as userService;
import 'model.dart';

@ApiClass(name: 'applications' , version: 'v1')
class ApplicationService {
  var supportedPlatform = ['android','ios'];

  String checkSupportedPlatform(String platform){
    var lowerCasePlatform = platform.toLowerCase();
    if (supportedPlatform.contains(lowerCasePlatform)){
      return lowerCasePlatform;
    }
    throw new RpcError(400, 'InvalidRequest', 'Unsuported platform, only $supportedPlatform supported');
  }

  Future<MDTApplication> findApplicationByAppId(String appId) async {
    var application = await mgrs.findApplicationByUuid(appId);
    if (application == null){
      throw new NotFoundError('Application not found');
    }
    return application;
  }

  @ApiMethod(method: 'POST', path: 'create')
  Future<Response> createApplication(CreateApplication createMsg) async{
    var platform = checkSupportedPlatform(createMsg.platform);
    var currentuser = userService.currentAuthenticatedUser();
    try {
      var appCreated = await mgrs.createApplication(createMsg.name,platform,description:createMsg.description,adminUser:currentuser);
      return new Response(200, toJson(appCreated, isAdmin:true));
    } on StateError catch (e) {
      var error = e;
      //  throw new BadRequestError( e.message);
      throw new RpcError(400, 'InvalidRequest', 'Unable to create app')
        ..errors.add(new RpcErrorDetail(reason: e.message));
    }
  }

  @ApiMethod(method: 'GET', path: 'search')
  Future<Response> allApplications({String platform}) async{
    var _platform = platform;
    if (_platform != null){
      _platform = checkSupportedPlatform(_platform);
    }
    List<ApplicationResponse> allApps = await mgrs.allApplications(platform:_platform);
    var currentuser = userService.currentAuthenticatedUser();
    return new Response(200, toJson(allApps,isAdmin:currentuser.isSystemAdmin));
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
      application = await mgrs.updateApplication(application,name:updateMsg.name,platform:updateMsg.platform,description:updateMsg.description);
      return new Response(200, toJson(application,isAdmin:true));
    }on StateError catch (e) {
      var error = e;
      //  throw new BadRequestError( e.message);
      throw new RpcError(400, 'InvalidRequest', 'Unable to update app')
        ..errors.add(new RpcErrorDetail(reason: e.message));
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

  /*@ApiMethod(method: 'PUT', path: 'app/{appId}/adminUser')

  @ApiMethod(method: 'DELETE', path: 'app/{appId}/adminUser')

  @ApiMethod(method: 'GET', path: 'app/{appId}/versions')

  @ApiMethod(method: 'GET', path: 'app/{appId}/versions/{version}')
*/
}

class UpdateApplication {
  @ApiProperty(required: false)
  String name;
  @ApiProperty(required: false)
  String description;
  @ApiProperty(required: false)
  String platform;
  UpdateApplication();
}
class CreateApplication {
  @ApiProperty(required: true)
  String name;
  @ApiProperty(required: true)
  String description;
  @ApiProperty(required: true)
  String platform;
  CreateApplication();
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