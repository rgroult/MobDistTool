import 'dart:io';
import 'dart:async';
import 'package:option/option.dart';
import 'package:rpc/rpc.dart';
import 'package:rpc/src/context.dart' as context;
import 'package:shelf_auth/shelf_auth.dart';
import 'package:shelf_exception_handler/shelf_exception_handler.dart';
import '../model/model.dart';
import '../managers/src/users_manager.dart' as users;
import '../managers/src/apps_manager.dart' as apps;
import 'json_convertor.dart';
import 'model.dart';


Future<Option<User>> authenticateUser(String username, String password) async {
  //return new Some(new Principal(("toto")));
  //search user
  var user = await users.findUser(username, password);
  if (user != null) {
    return new Some(new User(user));
  }
  return new None();
}

Future<Option<User>> findUser(String username) async {
  var user = await users.findUserByEmail(username);
  if (user != null) {
    return new Some(new User(user));
  }
  return new None();
}

usernameLookup(String username) async =>
  findUser(username);

MDTUser currentAuthenticatedUser() {
  var user = authenticatedContext().get().principal.dbUser;
  return user;
}


//usefull
// http://stackoverflow.com/questions/32255622/using-dart-rpc-and-shelf-auth-for-some-procedures
// https://pub.dartlang.org/packages/shelf_auth
//discovery : http://localhost:8080/api/discovery/v1/apis/users/v1/rest
@ApiClass(name: 'users', version: 'v1')
class UserService {
  @ApiMethod(method: 'POST', path: 'register')
  Future<Response> userRegister(RegisterMessage message) async {
    try {
      var userCreated = await users.createUser(message.name, message.email, message.password);
      //var responseJson = toJson(userCreated);
      // var test = context.context;
      return new Response(200, toJson(userCreated));
    } on StateError catch (e) {
      var error = e;
      //  throw new BadRequestError( e.message);
      throw new RpcError(400, 'InvalidRequest', 'Unable to register')
        ..errors.add(new RpcErrorDetail(reason: e.message));
    }
  }

  //user/login
  //http://localhost:8080/api/users/v1/login?login=toto&password=titi&type=test
  @ApiMethod(method: 'GET', path: 'login')
  Response userGetLogin() {
    var currentUser = currentAuthenticatedUser();
    return new Response(200, toJson(currentUser));
  }

  @ApiMethod(method: 'POST', path: 'login')
  Response userPostLogin(EmptyMessage message) {
    var currentUser = currentAuthenticatedUser();
    return new Response(200, toJson(currentUser));
  }

  @ApiMethod(method: 'GET', path: 'me')
  Response userMe() {
    var me = currentAuthenticatedUser();
    var response = toJson(currentUser, isAdmin:true);
    var allAdministratedApps = apps.findAllApplicationsForUser(me);
    var administratedAppJson = [];
    for (var app in allAdministratedApps){
      administratedAppJson.add(toJsonStringValues(app,['name','platform']));
    }
    response['administratedApplications'] = administratedAppJson;
    return new Response(200, response);
  }

  ///*{String login , String password,String type token or session}*/

  //user/logout
  //only work for session login
  @ApiMethod(method: 'GET', path: 'logout')
  VoidMessage userLgout() {

  }
}

class RegisterMessage {
  @ApiProperty(required: true)
  String email;
  @ApiProperty(required: true)
  String password;
  @ApiProperty(required: true)
  String name;

  RegisterMessage();
}

class EmptyMessage {

}

class EchoResponse {
  String result;

  EchoResponse();
}