import 'package:test/test.dart';
import 'dart:async';
import 'package:objectory/objectory_console.dart';
import '../bin/managers/users_manager.dart' as user_mgr;
import '../bin/config/mongo.dart' as mongo;

Future main() async {
  await mongo.initialize();
  test ("Clean database", ()async {
    await objectory.dropCollections();
  });
  group ("User", () {
    var email = 'test@test.com';
    var password = 'password';
    var name = 'user name';

    test("Create user", () async {
      var user = await user_mgr.createUser(name, email, password);
      expect(user, isNotNull);
    });
    test("Create same user", () async {
      //try to create same user
      var sameUser =  user_mgr.createUser(name, email, password);
      expect(sameUser, throwsStateError);
    });
    test("retrieve user", () async {
      var user = await user_mgr.findUserByEmail(email);
      expect(user.name, equals(name));
      expect(user.email, equals(email));
      expect(user.password, equals(password));
      expect(user.isSystemAdmin, equals(false));
    });
    test("modify user", () async {
      var user = await user_mgr.findUserByEmail(email);
      var newname = "newName";
      user.name = newname;
      user.isSystemAdmin = true;
      user.save();

      user = await user_mgr.findUserByEmail(email);
      expect(user.name, equals(newname));
      expect(user.isSystemAdmin, equals(true));
    });
    /* test("String.trim() removes surrounding whitespace", () {
    var string = "  foo ";
    expect(string.trim(), equals("foo"));
  });*/
  });
}