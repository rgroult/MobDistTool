import 'dart:async';
import 'dart:core';
import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';
import '../../bin/server.dart' as server;
import 'rpc_commons.dart';
import '../../server/managers/managers.dart' as mgrs;
import 'user_service_test.dart';

var baseAppUri = "/api/applications/v1";

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

  /* test("stop server", () async {
    // HttpApiResponse response = await _sendRequest('GET', 'get/simple');
    var result = httpServer.close(force:true);
  });*/
}

var userRegistration1 = {"email":"apptest@test.com", "password":"passwd", "name":"app user 1"};
var userRegistration2 = {"email":"apptest2@test.com", "password":"passwd", "name":"app user 2"};
var applicationCreationiOS = {"name":"Application test ios", "description":"Full app description", "platform":"ios"};
var applicationCreationAndroid = {"name":"Application test android", "description":"Full app description", "platform":"android"};

void createAndLogin(){
  //register
  test("Register", () async {
    await registerUser(userRegistration1,mustSuccessful:true);
    await registerUser(userRegistration2,mustSuccessful:true);
  });

  //login
  test("Login", () async {
    await loginTest(userRegistration1["email"], userRegistration1["password"], mustSuccessful:true,name:userRegistration1["name"]);
  });
}

void allTests() {
  createAndLogin();

  test("Create app KO bad platform", () async {
    var appInfos = new Map.from(applicationCreationiOS);
    appInfos["platform"] = "fakePlatform";

    var response = await sendRequest('POST', '${baseAppUri}/create', body: JSON.encode(appInfos));
    var responseJson = parseResponse(response);
    expect(response.statusCode, equals(400));

    expect(responseJson["error"]["code"], equals(400));
  });

  test("Create app KO missing platform", () async {
    var appInfos = new Map.from(applicationCreationiOS);
    appInfos.remove("platform");

    var response = await sendRequest('POST', '${baseAppUri}/create', body: JSON.encode(appInfos));
    var responseJson = parseResponse(response);
    expect(response.statusCode, equals(400));

    expect(responseJson["error"]["code"], equals(400));
  });

  test("Create app OK", () async {
    var appInfos = new Map.from(applicationCreationiOS);

    var response = await sendRequest('POST', '${baseAppUri}/create', body: JSON.encode(appInfos));
    var responseJson = parseResponse(response);
    expect(response.statusCode, equals(200));
    expect(responseJson["data"]["name"],equals(appInfos["name"]));
    expect(responseJson["data"]["description"],equals(appInfos["description"]));
    expect(responseJson["data"]["platform"],equals(appInfos["platform"]));
    expect(responseJson["data"]["adminUsers"].length,equals(1));
  });

  test("Create app KO duplicate app", () async {
    var appInfos = new Map.from(applicationCreationiOS);

    var response = await sendRequest('POST', '${baseAppUri}/create', body: JSON.encode(appInfos));
    var responseJson = parseResponse(response);
    expect(response.statusCode, equals(400));

    expect(responseJson["error"]["code"], equals(400));
  });

  test("Search app KO", () async {
    var response = await sendRequest('GET', '${baseAppUri}/search?platform=fakePlatform');
    expect(response.statusCode, equals(400));
    var responseJson = parseResponse(response);
    expect(responseJson["error"]["code"], equals(400));
  });

  test("Search app", () async {
    //create another app
    var appInfos = new Map.from(applicationCreationAndroid);
    var response = await sendRequest('POST', '${baseAppUri}/create', body: JSON.encode(appInfos));
    var responseJson = parseResponse(response);
    expect(response.statusCode, equals(200));

    var allIosApps = await sendRequest('GET', '${baseAppUri}/search?platform=ios');
    responseJson = parseResponse(allIosApps);
    expect(allIosApps.statusCode, equals(200));
    responseJson = parseResponse(allIosApps);
    expect(responseJson["list"].length, equals(1));

    var allAndroidApps = await sendRequest('GET', '${baseAppUri}/search?platform=android');
    expect(allAndroidApps.statusCode, equals(200));
    responseJson = parseResponse(allAndroidApps);
    expect(responseJson["list"].length, equals(1));

    var allApps = await sendRequest('GET', '${baseAppUri}/search');
    expect(allApps.statusCode, equals(200));
    responseJson = parseResponse(allApps);
    expect(responseJson["list"].length, equals(2));

  });

  //ar applicationCreation = {"name":"Application test", "description":"Full app description", "platform":"ios"};
  test("Update app OK", () async {
    var allIosApps = await sendRequest('GET', '${baseAppUri}/search?platform=ios');
    var responseJson = parseResponse(allIosApps);
    var app = responseJson["list"].first;

    var appInfos = new Map.from(applicationCreationiOS);
    var newDesc = "new description";
    appInfos["description"] = newDesc;

    var response = await sendRequest('PUT', '${baseAppUri}/app/${app["uuid"]}', body: JSON.encode(appInfos));
    expect(response.statusCode, equals(200));
    responseJson = parseResponse(response);
  });

  test("Update app KO", () async {
    var allIosApps = await sendRequest('GET', '${baseAppUri}/search?platform=ios');
    var responseJson = parseResponse(allIosApps);
    var appIOS = responseJson["list"].first;

    var response = await sendRequest('PUT', '${baseAppUri}/app/${appIOS["uuid"]}', body: JSON.encode(applicationCreationAndroid));
    expect(response.statusCode, equals(500));
    responseJson = parseResponse(response);

  });
}