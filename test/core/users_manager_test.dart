// Copyright (c) 2016, Rémi Groult.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'dart:async';
import 'package:objectory/objectory_console.dart';
import '../../server/managers/managers.dart' as mdt_mgr;
import '../../server/config/src/mongo.dart' as mongo;

void main() {
  test("init database", () async {
    var value = await mongo.initialize();
  });

  allTests();

  test("close database", () async {
    var value = await objectory.close();
  });
}

void allTests()  {
  group ("User", () {
    var email = 'test@test.com';
    var password = 'password';
    var name = 'user name';

    test("Create user empty fields", () async {
      //expect(new Future.error(new StateError("bad state")), throwsStateError);
      var user = mdt_mgr.createUser(name, null, password);
      expect(user, throwsStateError);
      user =  mdt_mgr.createUser(name, email, null);
      expect(user, throwsStateError);
    });

    test("Create user", () async {
      var user =  await mdt_mgr.createUser(name, email, password);
      expect(user, isNotNull);
      expect(user.name, equals(name));
      expect(user.email, equals(email));
      expect(user.password, equals(mdt_mgr.generateHash(password,user.salt)));
    });

    test("Create same user", () async {
      //try to create same user
      var sameUser = mdt_mgr.createUser(name, email, password);
      expect(sameUser, throwsStateError);
    });

    test("retrieve user", () async {
      var user =  await mdt_mgr.findUserByEmail(email);
      expect(user.name, equals(name));
      expect(user.email, equals(email));
      expect(user.password, equals(mdt_mgr.generateHash(password,user.salt)));
      expect(user.isSystemAdmin, equals(false));
    });

    test("authenticate user Not found", () async {
      var user = await mdt_mgr.findUser("anotheremail",'badpassword');
      expect(user, isNull);
    });

    test("authenticate user KO", () async {
      var user = await mdt_mgr.findUser(email,'badpassword');
      expect(user, isNull);
    });

    test("authenticate user OK", () async {
      var user = await mdt_mgr.findUser(email,password);
      expect(user.name, equals(name));
      expect(user.email, equals(email));
    });

    test("modify user", () async {
      var user = await mdt_mgr.findUserByEmail(email);
      var newname = "newName";
      user.name = newname;
      user.isSystemAdmin = true;
      await user.save();

      user = await mdt_mgr.findUserByEmail(email);
      expect(user.name, equals(newname));
      expect(user.isSystemAdmin, equals(true));
    });

    test("alls users", () async {
      var allUsers = await mdt_mgr.allUsers();
      expect(allUsers.length,equals(1));
    });

    test("search users", () async {
      await mdt_mgr.createUser("user", "testa@test.com", "password");
      await mdt_mgr.createUser("user", "testzzzzz@test.com", "password");
      await mdt_mgr.createUser("user", "testc@test.com", "password");

      var searchUsers = await mdt_mgr.searchUsers(1,0,20,"createdAt",true);
      expect(searchUsers.first.email,equals("test@test.com"));
      expect(searchUsers.last.email,equals("testc@test.com"));

      searchUsers = await mdt_mgr.searchUsers(1,0,20,"createdAt",false);
      expect(searchUsers.first.email,equals("testc@test.com"));
      expect(searchUsers.last.email,equals("test@test.com"));

      searchUsers = await mdt_mgr.searchUsers(1,0,20,"email",false);
      /*print("Email descending");
      for (var user in searchUsers){
        print("${user.email}, ${user.getProperty("createdAt")}");
      }*/
      expect(searchUsers.first.email,equals("testzzzzz@test.com"));
      expect(searchUsers.last.email,equals("test@test.com"));

      searchUsers = await mdt_mgr.searchUsers(1,0,20,"email",true);
      /* print("Email ascending");
      for (var user in searchUsers){
        print(user.email);
      }*/
      expect(searchUsers.first.email,equals("test@test.com"));
      expect(searchUsers.last.email,equals("testzzzzz@test.com"));

      searchUsers = await mdt_mgr.searchUsers(1,2,1,"email",true);
      expect(searchUsers.last.email,equals("testc@test.com"));
    });

    test("delete user", () async {
      var user = await mdt_mgr.findUserByEmail(email);
      expect(user.email, equals(email));
      await mdt_mgr.deleteUserByEmail(email);
      //retrieve user ?
      user = await mdt_mgr.findUserByEmail(email);
      expect(user,isNull);
    });

    test("delete user again", () async {
      var result = false;
      try {
        var result = await mdt_mgr.deleteUserByEmail(email);
      }on StateError catch (e){
        result = true;
       expect((e is  mdt_mgr.UserError), isTrue);
    }
      expect(result,isTrue);
    });
  });
}