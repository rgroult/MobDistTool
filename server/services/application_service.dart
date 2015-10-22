import 'dart:io';
import 'dart:async';
import 'package:rpc/rpc.dart';
//import '../../packages/rpc/src/context.dart' as context;
import '../managers/managers.dart';

@ApiClass(name: 'applications' , version: 'v1')
class ApplicationService {
  @ApiMethod(method: 'GET', path: 'all')
  List<ApplicationResponse> allApplications({String platform}) async{
    return new List();
    //retrieve user
    //var user = context
  }

  @ApiMethod(method: 'GET', path: 'all1')
  ApplicationResponse userLogin() {
    return new ApplicationResponse(null)
      ..result="Hello world";
  }
}

class ApplicationResponse {
  String result;
  AppResponse(MDTApplication app){

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