import 'dart:async';
import 'package:objectory/objectory_console.dart';
import '../model/model.dart';
import 'errors.dart';

class UserError extends StateError {
  UserError(String msg) : super(msg);
}

var userCollection = objectory[MDTUser];

Future<MDTUser> authenticateUser(String email, String password) async {
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
  return await userCollection.findOne(where.eq("externalTokenId", uuid));
}

Future<MDTUser> findUserByEmail(String email) async {
  return await userCollection.findOne(where.eq("email", email));
}

Future<MDTUser> createUser(String name, String email, String password,
    {bool isSystemAdmin: false}) async {
  if (email == null || email.isEmpty) {
    //return new Future.error(new StateError("bad state"));
    throw new UserError('email must be not null');
  }
  if (password == null || password.isEmpty) {
    throw new UserError('password must be not null');
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

  return await createdUser.save();
}

String _generateHash(String password) {
  return password;
}
