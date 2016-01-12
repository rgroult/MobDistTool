import 'dart:async';
import '../../../packages/objectory/objectory_console.dart';
import '../../model/model.dart';
import 'apps_manager.dart' as app_mgr;
import '../errors.dart';

var userCollection = objectory[MDTUser];

Future<List<MDTUser>> allUsers() {
  return userCollection.find();
}

Future<MDTUser> findUser(String email, String password) async {
  if (email.isEmpty || password.isEmpty) {
    return null;
  }
  var user = await userCollection.findOne(where.eq("email", email));
  if (user != null) {
    if (user.password == _generateHash(password)) {
      return user;
    }
  }
  return null;
}

Future<MDTUser> findUserByUuid(String uuid) async {
  return await userCollection.find(where.eq("uuid", uuid));
}

Future<MDTUser> findUserByToken(String token) async {
  return await userCollection.findOne(where.eq("externalTokenId", token));
}

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
    {bool isSystemAdmin: false}) async {
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

  var createdUser = new MDTUser()
    ..name = name
    ..email = email
    ..password = _generateHash(password)
    ..isSystemAdmin = isSystemAdmin;

  await createdUser.save();

  return createdUser;
}

String _generateHash(String password) {
  return password;
}
