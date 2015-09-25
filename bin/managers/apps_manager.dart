import 'dart:async';
import 'package:objectory/objectory_console.dart';
import '../model/model.dart';
import 'errors.dart';

/*
class MDTApplication extends MDTBaseObject {
  String name;
  String platform;
  List<MDTUser> adminUsers;
  MDTArtifact lastVersion;
}
 */

class AppError extends StateError {
  AppError(String msg) : super(msg);
}

var appCollection = objectory[MDTApplication];

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

Bool deleteApplication(String name, String platform) async {
  var app = await findApplication(name,platform);
  if (app != null) {
    await app.remove();
    return true;
  }
  return false;
}

Future<MDTApplication> addAdminApplication(MDTApplication app, MDTUser user) async {
  if (app.adminUsers.contains(user)) {
    //do nothing
    return new Future(app);
  }
  app.adminUsers.add(user)
  return app.save();
}

Future<MDTApplication> removeAdminApplication(MDTApplication app, MDTUser user) async {
  if (app.adminUsers.contains(user) == false) {
    //do nothing
    return new Future(app);
  }
  app.adminUsers.remove(user);
  app.save();
  return app;
}
