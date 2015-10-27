import 'dart:async';
import 'dart:core';
import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';
import '../../bin/server.dart' as server;
import 'rpc_commons.dart';
import '../../server/managers/managers.dart' as mgrs;
import 'user_service_test.dart';

void main() {
  //start server
  HttpServer httpServer = null;

  test("start server", () async {
    httpServer = await server.startServer();
  });

  test("configure values", () async {
    baseUrlHost = "http://${httpServer.address.host}:${httpServer.port}";
    print('baseUrlHost : $baseUrlHost');
  });

  createAndLogin();
  allTests();

  /* test("stop server", () async {
    // HttpApiResponse response = await _sendRequest('GET', 'get/simple');
    var result = httpServer.close(force:true);
  });*/
}

var userRegistration = {"email":"apptest@test.com","password":"passwd","name":"app user"};

void createAndLogin(){
  //register
  test("Register", () async {
    await registerUser(userRegistration,mustSuccessful:true);
  });

  //login
  test("Login", () async {
    await loginTest(userRegistration["email"], userRegistration["password"], mustSuccessful:true,name:userRegistration["name"]);
  });
}

void allTests() {

}