import 'dart:async';
import 'dart:core';
import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';
import '../../bin/server.dart' as server;
import 'rpc_commons.dart';
import '../../server/managers/managers.dart' as mgrs;

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

  allTests();
/*
  test("stop server", () async {
    // HttpApiResponse response = await _sendRequest('GET', 'get/simple');
    var result = httpServer.close(force:true);
  });*/
}

Future loginTest(String login, String password, {bool mustSuccessful:true, String name}) async {
  var response = await sendRequest('POST', '/api/users/v1/login', body:'username=${login}&password=${password}', contentType:'application/x-www-form-urlencoded');
  print("response ${response.body}");
  var responseJson = parseResponse(response);
  if (mustSuccessful) {
    expect(response.statusCode, equals(200));
    expect(responseJson["data"]["email"], equals(login));
    if (name != null) {
      expect(responseJson["data"]["name"], equals(name));
    }
  } else {
    expect(response.statusCode, equals(401));
  }
}

void allTests() {

  test("Authent KO", () async {
    await loginTest("toto", "titi", mustSuccessful:false);
    /*var response =  await sendRequest('POST','/api/users/v1/login',body:'login=toto&password=titi',contentType:'application/x-www-form-urlencoded');
    //var responseJson = parseResponse(response);
    print("response ${response.body}");
    expect(response.statusCode, equals(401));*/
  });

  var userRegistration = {"email":"test@test.com", "password":"passwd", "name":"toto"};
  test("Register KO email", () async {
    var userWithoutEmail = new Map.from(userRegistration);
    userWithoutEmail.remove("email");

    var response = await sendRequest('POST', '/api/users/v1/register', body: JSON.encode(userWithoutEmail));
    expect(response.statusCode, equals(400));
    var responseJson = parseResponse(response);
    expect(responseJson["error"]["code"], equals(400));

  });

  test("Register KO password", () async {
    var userWithoutPassword = new Map.from(userRegistration);
    userWithoutPassword.remove("password");

    var response = await sendRequest('POST', '/api/users/v1/register', body: JSON.encode(userWithoutPassword));
    expect(response.statusCode, equals(400));
    var responseJson = parseResponse(response);
    expect(responseJson["error"]["code"], equals(400));

  });

  test("Register KO name", () async {
    var userWithoutName = new Map.from(userRegistration);
    userWithoutName.remove("name");

    var response = await sendRequest('POST', '/api/users/v1/register', body: JSON.encode(userWithoutName));
    expect(response.statusCode, equals(400));
    var responseJson = parseResponse(response);
    expect(responseJson["error"]["code"], equals(400));

  });

  test("Register OK", () async {
    var response = await sendRequest('POST', '/api/users/v1/register', body: JSON.encode(userRegistration));
    //print("response ${response.body}");
    expect(response.statusCode, equals(200));
    var responseJson = parseResponse(response);
    expect(responseJson["data"]["name"], equals(userRegistration["name"]));
    expect(responseJson["data"]["email"], equals(userRegistration["email"]));
  });

  test("Authent OK", () async {
    await loginTest(userRegistration["email"], userRegistration["password"], mustSuccessful:true,name:userRegistration["name"]);
/*
    var response =  await sendRequest('POST','/api/users/v1/login',body:'username=${userRegistration["email"]}&password=${userRegistration["password"]}',contentType:'application/x-www-form-urlencoded');
    print("response ${response.body}");
    var responseJson = parseResponse(response);
    expect(response.statusCode, equals(200));
    expect(responseJson["data"]["name"], equals(userRegistration["name"]));
    expect(responseJson["data"]["email"], equals(userRegistration["email"]));*/
  });
}