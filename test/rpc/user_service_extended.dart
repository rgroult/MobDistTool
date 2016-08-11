// Copyright (c) 2016, Rémi Groult.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.
import 'dart:async';
import 'dart:core';
import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';
import '../../bin/server.dart' as server;
import 'rpc_commons.dart';
import 'rpc_utilities.dart';
import 'user_service_test.dart';

void main() {
  //start server
  HttpServer httpServer = null;

  test("start server", () async {
    httpServer = await server.startServer(resetDatabaseContent:true);
  });

  test("configure values", () async {
    baseUrlHost = "http://${httpServer.address.host}:${httpServer.port}";
    print('baseUrlHost : $baseUrlHost');
  });

  allTests();

  test("stop server", () async  {
    // HttpApiResponse response = await _sendRequest('GET', 'get/simple');
    await server.stopServer(force:true);
    print('server stopped');
  });
}


void allTests() {
  var appIOS = {};
  test("Create User", () async {
    await registerUser(userRegistration1,mustSuccessful:true);
  });

  //login
  test("Login", () async {
    await loginTest(userRegistration1["email"], userRegistration1["password"], mustSuccessful:true,name:userRegistration1["name"]);
  });

  test("Create App", () async {
    var response = await createApplication(infos:applicationCreationiOS);

    expect(response["status"], equals(200));

    appIOS = response["data"];
  });


  test("Retrieve Me", () async {
    var response = await sendRequest('GET','/api/users/v1/me');
    expect(response.statusCode, equals(200));
    var responseJson = parseResponse(response);
    expect(responseJson["data"]["email"], equals(userRegistration1["email"]));
    expect(responseJson["data"]["name"], equals(userRegistration1["name"]));
    expect(responseJson["data"]["favoritesApplicationsUUID"], isNull);
    expect(responseJson["data"]["administratedApplications"], isNotNull);
    expect(responseJson["data"]["administratedApplications"][0]["uuid"], appIOS["uuid"]);
  });

  test("Update Favorite KO", () async {
    var appId = appIOS["uuid"];
    var userUpdate = {"email":userRegistration1["email"], "favoritesApplicationUUID":["fakeId"]};

    var response = await sendRequest('PUT','/api/users/v1/user' ,body: JSON.encode(userUpdate));
    var responseJson = parseResponse(response);
    expect(response.statusCode, equals(200));
    var favorites = JSON.decode(responseJson["data"]["favoritesApplicationsUUID"]);
    expect(favorites,isEmpty);
  });

  test("Update Favorite OK", () async {
    var appId = appIOS["uuid"];
    var userUpdate = {"email":userRegistration1["email"], "favoritesApplicationUUID":[appId]};
    var response = await sendRequest('PUT','/api/users/v1/user' ,body: JSON.encode(userUpdate));
    var responseJson = parseResponse(response);
    expect(response.statusCode, equals(200));
    var favorites = JSON.decode(responseJson["data"]["favoritesApplicationsUUID"]);
    expect(favorites.length, equals(1));
    expect(favorites[0], equals(appId));

    //me must also be correct
    response = await sendRequest('GET','/api/users/v1/me');
    responseJson = parseResponse(response);
    var favoritesMe = JSON.decode(responseJson["data"]["favoritesApplicationsUUID"]);
    expect(favorites, favoritesMe);
  });
}