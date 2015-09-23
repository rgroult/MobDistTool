import 'dart:async';
import 'package:objectory/objectory_console.dart';
import '../model/model.dart';
import 'errors.dart';


class UserError extends StateError {
  UserError(String msg) : super(msg);
}

//lass UsersManager {
  /** Top-level root [UsersManager]. */
  //static Logger get sharedInstance => new UsersManager();

  var userCollection = objectory[MDTUser];

  Future authenticateUser(String email, Sring password) async {
    if !email || !password {
     return null
    }
    var user = await userCollection.findOne (where.eq("email", email));
    if user {
      if user.password === _generated(password) {
          return user
      }
    }
   return null
  }

  Future findUserByUuid(String uuid) async {
     return  await userCollection.find(where.eq("uuid", uuid));
   }

  Future findUserByToken(String token) async  {
    return  await userCollection.findOne(where.eq("externalTokenId", uuid));
  }

  Future findUserByEmail(String email) async  {
   return  await userCollection.findOne(where.eq("email", email));
  }

  Future createUser(String name, String email, String password, { bool isSystemAdmin: false  }) async  {
    //find another user
    var existingUser = await userCollection.findOne(where.eq('email', email));
    if (existingUser != null ) {
      //user with same email already exist
      throw new UserError('User already exist with this email');
    }

    var createdUser = new MDTUser()
      ..name = name
      ..email = email
      ..password =  _generateHash(password)
      ..isSystemAdmin = isSystemAdmin;

    return await createdUser.save();
  }

  String _generateHash(String password) {
    return password;
  }
//}

