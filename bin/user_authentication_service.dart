
import 'dart:io';

import 'package:rpc/rpc.dart';
import 'package:rpc/src/context.dart' as context;
import 'dart:async';
import 'model/model.dart';
import 'managers/users_manager.dart';


//usefull
// http://stackoverflow.com/questions/32255622/using-dart-rpc-and-shelf-auth-for-some-procedures
// https://pub.dartlang.org/packages/shelf_auth
@ApiClass(name: 'authenticate' , version: 'v1')
class UserAuthenticationService {

  //user/login
  @ApiMethod(method: 'GET', path: 'user/login')
  EchoResponse userLogin({String login , String password,String type/* token or session*/}) {
    var test = context.context;
    return new EchoResponse()
        ..result="login "+login + " password :"+password + " type :"+type ;
  }

  //user/logout
  //only work for session login
  @ApiMethod(method: 'GET', path: 'user/logout')
  VoidMessage userLgout() {

  }
}

class EchoResponse {
  String result;
  EchoResponse();
}