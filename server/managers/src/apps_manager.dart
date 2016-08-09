// Copyright (c) 2016, the Mobile App Distribution Tool project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../config/src/mongo.dart' as mongo;
import '../../model/redstone_model.dart';
import '../errors.dart';
//import 'artifacts_manager.dart' as artifact_mgr;
import '../../utils/utils.dart';

var UuidGenerator = new Uuid();

var _appCollectionName = "MDTApplication";

Future<mongo.MongoDb> connection() async {
  return mongo.getConnection();
}

Future<List<MDTApplication>> allApplications({String platform}) async{
  if (platform == null) {
    //var all =  appCollection.find();
    return (await connection()).find(_appCollectionName,MDTApplication);
  }else {
    return  (await connection()).find(_appCollectionName,MDTApplication,mongo.where.eq("platform", platform));
  }
}

Future<MDTApplication> createApplication(String name, String platform,
    {String description,MDTUser adminUser,String base64Icon,bool maxVersionCheckEnabled}) async {
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
    ..platform = platform
    ..apiKey = UuidGenerator.v4()
    ..description = description
    ..uuid = UuidGenerator.v4()
    ..base64IconData = base64Icon;

  setMaxCheckVersion(createdApp,maxVersionCheckEnabled);

  if (description != null) createdApp.description = description;

  createdApp.adminUsers = createdApp.adminUsers != null ? createdApp.adminUsers : [];

  //if (adminUser != null) createdApp.adminUsers.add(adminUser.id);

  await saveOrUpdateApp(createdApp);
  print("Crated ${createdApp.adminUsers}");
  return createdApp;
}

Future updateApplication(MDTApplication app, {String name, String platform, String description,String base64Icon,bool maxVersionCheckEnabled}) async {
  //find if other app with same name/platform
  var newName = name!=null ? name : app.name;
  var newPlatform = platform!=null? platform : app.platform;
  var alreadyPresentApp = await findApplication(newName, platform);
  if (alreadyPresentApp != null && alreadyPresentApp.uuid != app.uuid) {
    throw new AppError('App already exist with this name and platform');
  }else {
    app.name = newName;
    app.platform = newPlatform;
    if (description != null){
      app.description = description;
    }
    if (base64Icon != null){
      app.base64IconData = base64Icon;
    }

    setMaxCheckVersion(app,maxVersionCheckEnabled);
  }

  await saveOrUpdateApp(app);
  return app;
}

void setMaxCheckVersion(MDTApplication app,bool maxVersionCheckEnabled){
  if (maxVersionCheckEnabled !=null){
    if (maxVersionCheckEnabled){
      if (app.maxVersionSecretKey == null){ //not enabled?
        app.maxVersionSecretKey = randomString(15);
      }
    }else{
      app.maxVersionSecretKey = null;
    }
  }
}

bool isAdminForApp(MDTApplication app, MDTUser user){
  if (user.isSystemAdmin) return true;

  return app.adminUsers.contains(user);
}

Future saveOrUpdateApp(MDTApplication app) async{
  if (app.id != null) {
    return (await connection()).update(_appCollectionName,mongo.where.eq("uuid", app.uuid),app);
  }else {
    return (await connection()).save(_appCollectionName,app);
}

}

Future<MDTApplication> _findApplication(conn, selector) => conn.findOne(_appCollectionName,MDTApplication,selector);

Future<MDTApplication> findApplicationByApiKey(String apiKey) async {
  return await _findApplication(await connection(),mongo.where.eq("apiKey", apiKey));
}

Future<MDTApplication> findApplicationByUuid(String uuid) async {
  return await _findApplication(await connection(),mongo.where.eq("uuid", uuid));
}

Future<MDTApplication> findApplication(String name, String platform) async {
  return await _findApplication(await connection(),mongo.where.eq('name', name).eq('platform', platform));
}

Future<List<MDTApplication>> findAllApplicationsForUser(MDTUser user,{Future<mongo.MongoDb> providedConn}) async {
  var conn = providedConn != null ? providedConn : connection();
  await conn;
  return conn.findOne(_appCollectionName,MDTApplication,mongo.where.eq('adminUsers',user));
  //return appCollection.find(where.eq('adminUsers',user.dbRef));
}

Future deleteApplication(String name, String platform) async {
  var app = await findApplication(name,platform);
  return deleteApplicationByObject(app);
}

Future deleteApplicationByObject(MDTApplication app) async {
  if (app != null) {
    var conn = connection();
    //delete artifacts
    //await artifact_mgr.deleteAllArtifacts(app,artifact_mgr.defaultStorage,providedConn:conn);
    return conn.remove(_appCollectionName,mongo.where.eq("uuid", app.uuid));

  }
  return new Future.value(null);
}

Future deleteUserFromAdminUsers(MDTUser user, {Future<mongo.MongoDb> providedConn }) async {
  var conn = providedConn != null ? providedConn : connection();

  //Good way
  /*var apps = await appCollection.find(where.eq('adminUsers.email',user.email));
  for (app in apps) {
    removeAdminApplication(app,user);
  }*/
  //bad way
  var allApps = await findAllApplicationsForUser(user,providedConn:conn);
  await conn;
  var toWait = [];
  for (var app in allApps){
    await removeAdminApplication(app,user);
    //toWait.add(removeAdminApplication(app,user));
  }
  await Future.wait(toWait);
  //var newallApps = await appCollection.find();
  return new Future.value(null);
}

Future<MDTApplication> addAdminApplication(MDTApplication app, MDTUser user) async {
  if (isAdminForApp(app,user)) {
    //do nothing
    return new Future.value(app);
  }
 // app.adminUsers.add(app.adminUsers.internValue(user));
  app.adminUsers.add(user);
  return saveOrUpdateApp(app);
}

Future<MDTApplication> removeAdminApplication(MDTApplication app, MDTUser user) async {
  if (isAdminForApp(app,user) == false) {
    //do nothing
    return new Future.value(app);
  }
  app.adminUsers.remove(user);
  return saveOrUpdateApp(app);
  //return app.save();
}

