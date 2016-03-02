// Copyright (c) 2016, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:objectory/objectory_console.dart';
import '../../model/model.dart';
import 'apps_manager.dart' as app_mgr;
import '../errors.dart';
import '../../utils/utils.dart' as utils;

var userCollection = objectory[MDTUser];
var UuidGenerator = new Uuid();

Future<List<MDTUser>> allUsers() {
  return userCollection.find();
}

Future<MDTUser> findUser(String email, String password) async {
  if (email.isEmpty || password.isEmpty) {
    return null;
  }
  var user = await userCollection.findOne(where.eq("email", email));
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

Future<MDTUser> findUserByEmail(String email) async {
  return await userCollection.findOne(where.eq("email", email));
}

Future deleteUserByEmail(String email) async {
  var user = await findUserByEmail(email);

  if (user == null) {
    throw new UserError('user not found');
  }

  //delete user reference in apps
  await app_mgr.deleteUserFromAdminUsers(user);

  return user.remove();
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
  //find another user
  var existingUser = await userCollection.findOne(where.eq('email', email));
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

  await createdUser.save();

  return createdUser;
}

//first page : pageIndex = 1
Future<List<MDTUser>> searchUsers(int pageIndex,int limitPerPage) async{
  var page = max(1,pageIndex);
  var numberToSkip = (page-1)*limitPerPage;

  return userCollection.find(where.sortBy("email",descending:true).skip(numberToSkip).limit(limitPerPage));
}

String generateHash(String password,String salt) {
  var stringToHash = "$password:$salt";
  return utils.generateHash(stringToHash);
}

String _generateSalt(){
  return utils.randomString(10);
}

