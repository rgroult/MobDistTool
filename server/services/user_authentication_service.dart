import 'dart:io';
import 'dart:async';
import 'package:option/option.dart';
import 'package:rpc/rpc.dart';
import 'package:rpc/src/context.dart' as context;
import 'package:shelf_auth/shelf_auth.dart';

import '../model/model.dart';
import '../managers/src/users_manager.dart' as users;
import 'package:shelf_exception_handler/shelf_exception_handler.dart';


Future<Option<User>> authenticateUser(String username, String password ) async {
  //return new Some(new Principal(("toto")));
  //search user
  var user = await users.authenticateUser(username, password);
  if (user!=null) {
    return new Some(new User(user));
  }
  return new None();
}


func usernameLookup(String username) async =>
   new Some(new Principal(username));
/*
MDTUser currentAuthenticatedUser(){
  var user = authenticatedSessionContext()
      .flatMap((SessionAuthenticatedContext context) => context.principal)
      .flatMap((User user) => user.dbUser).orNull();

  return user;
}*/


//usefull
// http://stackoverflow.com/questions/32255622/using-dart-rpc-and-shelf-auth-for-some-procedures
// https://pub.dartlang.org/packages/shelf_auth
//discovery : http://localhost:8080/api/discovery/v1/apis/users/v1/rest
@ApiClass(name: 'users' , version: 'v1')
class UserAuthenticationService {

  //user/login
  //http://localhost:8080/api/users/v1/login?login=toto&password=titi&type=test
  @ApiMethod(method: 'GET', path: 'login')
  EchoResponse userGetLogin() {
    var test = context.context;
    return new EchoResponse()
        ..result="login "+"login" + " password :"+"password" + " type :"+"type" ;
  }

  @ApiMethod(method: 'POST', path: 'login')
  EchoResponse userPostLogin(EmptyMessage message) {
    var test = context.context;
    var authentContext = authenticatedContext;
    return new EchoResponse()
      ..result="login "+"login" + " password :"+"password" + " type :"+"type" ;
  }

  ///*{String login , String password,String type token or session}*/

  //user/logout
  //only work for session login
  @ApiMethod(method: 'GET', path: 'logout')
  VoidMessage userLgout() {

  }
}

class EmptyMessage {

}

class EchoResponse {
  String result;
  EchoResponse();
}