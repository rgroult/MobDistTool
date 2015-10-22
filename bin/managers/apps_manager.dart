import 'dart:async';
import 'package:objectory/objectory_console.dart';
import '../model/model.dart';
import 'errors.dart';
import 'artifacts_manager.dart' as artifact_mgr;

var appCollection = objectory[MDTApplication];

Future<List<MDTApplication>> allApplications() {
  return appCollection.find();
}

Future<MDTApplication> createApplication(String name, String platform,
    {MTDUser adminUser}) async {
  if (name == null || name.isEmpty) {
    //return new Future.error(new StateError("bad state"));
    throw new AppError('name must be not null');
  }
  if (platform == null || platform.isEmpty) {
    throw new AppError('platform must be not null');
  }

  //find another app
  var existingApp = await findApplication(name,platform);
      //await appCollection.findOne(where.eq('name', name, 'platform', platform));
  if (existingApp != null) {
    //app already exist
    throw new AppError('App already exist with this name and platform');
  }

  var createdApp = new MDTApplication()
    ..name = name
    ..platform = platform;

  var adminUsers = createdApp.adminUsers;

  if (adminUser != null) createdApp.adminUsers.add(adminUser);

  await createdApp.save();
  return createdApp;
}

Future<MDTApplication> findApplicationByApiKey(String apiKey) async {
  return await appCollection.findOne(where.eq("apiKey", apiKey));
}

Future<MDTApplication> findApplication(String name, String platform) async {
  return await appCollection.findOne(where.eq('name', name).eq('platform', platform));
}

Future<List<MDTApplication>> findAllApplicationsForUser(MDTUser user) {
  return appCollection.find(where.eq('adminUsers',user.dbRef));
}

Future deleteApplication(String name, String platform) async {
  var app = await findApplication(name,platform);
  if (app != null) {
    //delete artifacts
    await artifact_mgr.deleteAllArtifacts(app,artifact_mgr.defaultStorage);
    return  app.remove();
  }
  return new Future.value(null);
}

Future deleteUserFromAdminUsers(MDTUser user) async {
  //Good way
  /*var apps = await appCollection.find(where.eq('adminUsers.email',user.email));
  for (app in apps) {
    removeAdminApplication(app,user);
  }*/
  //bad way
  var allApps = await findAllApplicationsForUser(user);
  var toWait = [];
  for (var app in allApps){
    await removeAdminApplication(app,user);
    //toWait.add(removeAdminApplication(app,user));
  }
  await Future.wait(toWait);//.then(print("fini"));
  var newallApps = await appCollection.find();
  return new Future.value(null);
}

Future<MDTApplication> addAdminApplication(MDTApplication app, MDTUser user) async {
  if (app.adminUsers.contains(user)) {
    //do nothing
    return new Future.value(app);
  }
 // app.adminUsers.add(app.adminUsers.internValue(user));
  app.adminUsers.add(user);
  return app.save();
}

Future<MDTApplication> removeAdminApplication(MDTApplication app, MDTUser user) async {
  if (app.adminUsers.contains(user) == false) {
    //do nothing
    return new Future.value(app);
  }
  app.adminUsers.remove(user);
  app.setDirty("adminUsers");
  return app.save();
}

