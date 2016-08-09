// Copyright (c) 2016, the Mobile App Distribution Tool project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../config/src/mongo.dart' as mongo;
//import 'package:objectory/objectory_console.dart';
import '../../model/redstone_model.dart';
import 'apps_manager.dart' as app_mgr;
import '../errors.dart';
import '../../utils/utils.dart' as utils;
import '../../config/config.dart' as config;

//var userCollection = objectory[MDTUser];
var UuidGenerator = new Uuid();

var userCollectionName = "MDTUser";

Future<List<MDTUser>> allUsers() async{
  return (await connection()).find(userCollectionName,MDTUser);
}

Future<mongo.MongoDb> connection() async {
  return mongo.getConnection();
}
/*
Future<mongo.DbCollection userCollection() async{
 return  await mongo.getCollection("MDTUser");
  //return conn.collection("MDTUser");
}
*/
Future<MDTUser> findUser(String email, String password) async {
  if (email.isEmpty || password.isEmpty) {
    return null;
  }
  var user = await findUserByEmail(email);//(await connection()).findOne(userCollectionName,MDTUser,mongo.where.eq("email", email));
 // var user = await userCollection.findOne(where.eq("email", email));
  if (user != null) {
    if (user.password == generateHash(password,user.salt)) {
      return user;
    }
  }
  return null;
}

/*
Future<MDTUser> findUserByUuid(String uuid) async {
  return await userCollection.find(where.eq("uuid", uuid));
}

Future<MDTUser> findUserByToken(String token) async {
  return await userCollection.findOne(where.eq("externalTokenId", token));
}*/

Future createSysAdminIfNeeded() async{
  //find a sysadmin
  var conn = await connection();
  var aSysdmin = await conn.findOne(userCollectionName,MDTUser,mongo.where.eq("isSystemAdmin", true));
  //var aSysdmin = await userCollection.findOne(where.eq("isSystemAdmin", true));
  if (aSysdmin == null) {
    //Create a sysadmin
    var salt = _generateSalt();
    var createdUser = new MDTUser()
      ..name = "admin"
      ..email = config.currentLoadedConfig[config.MDT_SYSADMIN_INITIAL_EMAIL]
      ..salt = salt
      ..password = generateHash(
          config.currentLoadedConfig[config.MDT_SYSADMIN_INITIAL_PASSWORD],
          salt)
      ..isSystemAdmin = true
      ..isActivated = true;

    conn.insert(userCollectionName, createdUser);

    //await createdUser.save();
    print("Sys Admin ${createdUser.email}");
  }
}

Future<MDTUser> findByEmail(conn, email) => conn.findOne(userCollectionName,MDTUser,mongo.where.eq("email", email));

Future<MDTUser> findUserByEmail(String email) async {
  return await findByEmail(await connection(),email);
 // return await userCollection.findOne(where.eq("email", email));
}

Future updateUser(MDTUser user) async {
  return (await connection()).update(userCollectionName,mongo.where.eq("email", user.email),user);
}

Future deleteUserByEmail(String email) async {
  var conn = await connection();
  var user = await findByEmail(conn,email);

  if (user == null) {
    throw new UserError('user not found');
  }

  //delete user reference in apps
  await app_mgr.deleteUserFromAdminUsers(user);


  return conn.remove(userCollectionName,mongo.where.eq("email", email));

  //return user.remove();
}

Future<MDTUser> createUser(String name, String email, String password,
    {bool isSystemAdmin: false,bool isActivated: true}) async {
  if (email == null || email.isEmpty) {
    //return new Future.error(new StateError("bad state"));
    throw new UserError('email must be not null or empty');
  }
  if (password == null || password.isEmpty) {
    throw new UserError('password must be not null or empty');
  }
  var conn = await connection();
  //find another user
  var existingUser = await findByEmail(conn,email);
  if (existingUser != null) {
    //user with same email already exist
    throw new UserError('User already exist with this email');
  }

  var salt = _generateSalt();
  var createdUser = new MDTUser()
    ..name = name
    ..email = email
    ..salt = salt
    ..password = generateHash(password,salt)
    ..isSystemAdmin = isSystemAdmin
    ..isActivated = isActivated;

  if (isActivated == false){
    //generate activation token
    createdUser.activationToken = UuidGenerator.v4();
  }

  await conn.insert(userCollectionName,createdUser);

  return createdUser;
}

Future updateFavoritesApp(MDTUser user, List<String> appUID) async{
  List<String> favorites = null;
  if (appUID != null){
    favorites = new List<String>();
    for(String uuid in appUID){
        var appExist = await app_mgr.findApplicationByUuid(uuid);
        if (appExist != null){
          favorites.add(uuid);
        }
    }
  }
  try{
    user.favoritesApplicationsUUID = JSON.encode(favorites);
  }catch(e){
    user.favoritesApplicationsUUID = null;
  }

  return updateUser(user);
}

//first page : pageIndex = 1
Future<List<MDTUser>> searchUsers(int pageIndex,int numberToSkip, int limitPerPage) async{
  //var page = max(1,pageIndex);
  return (await connection()).find(userCollectionName,MDTUser,mongo.where.sortBy("email",descending:true).skip(numberToSkip).limit(limitPerPage));
}

String generateHash(String password,String salt) {
  var stringToHash = "$password:$salt";
  return utils.generateHash(stringToHash);
}

String _generateSalt(){
  return utils.randomString(10);
}

