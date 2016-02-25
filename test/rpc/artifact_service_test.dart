// Copyright (c) 2016, Rémi Groult.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:core';
import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../bin/server.dart' as server;
import 'rpc_commons.dart';
import 'rpc_utilities.dart';
import '../../server/managers/managers.dart' as mgrs;
import 'user_service_test.dart';


var baseArtUri = "/api/applications/v1";


void main() {
  //start server
  HttpServer httpServer = null;

  test("test start server", () async {
    httpServer = await server.startServer(resetDatabaseContent:true);
  });

  test("test configure values", () async {
    var serverBaseUrlHost = "http://${httpServer.address.host}:${httpServer.port}";
    print('baseUrlHost : $serverBaseUrlHost');
  });

  baseUrlHost = "http://localhost:8080";
  allTests();

  test("stop server", () async  {
    // HttpApiResponse response = await _sendRequest('GET', 'get/simple');
    await server.stopServer(force:true);
    print('server stopped');
  });
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

Future<http.Response>  uploadArtifact(String apiKey,String branch,String version, String name,{String jsonField,String artifactName}) async{
  var httprequest = new http.MultipartRequest('POST',Uri.parse("${baseUrlHost}/api/in/v1/artifacts/${apiKey}/master/$version/$name"));
  var artifactFilename = 'core/artifact_sample.txt';
  if (artifactName != null){
    artifactFilename = artifactName;
  }
  var filePart = await http.MultipartFile.fromPath('artifactFile', Directory.current.path+'/test/$artifactFilename');
  httprequest.files.add(filePart);
  httprequest.fields['sortIdentifier'] = 'sortId_$version';
  var tags = new Map();
  tags['tag1'] = "test tag1";
  tags['tag2'] = "test tag2";
  if (jsonField != null){
    httprequest.fields['jsonTags'] = jsonField;
  }

  var response = await http.Response.fromStream(await httprequest.send());
  //var responseJson = parseResponse(response);

  return response;
}

void allTests() {
  Map currentUser;
  Map currentApp;
  Map currentArtifact;

  test("Upload artifact OK Android", () async {
    var user = await createAndLoginUser();
    var application = await createApplication(infos:applicationCreationAndroid);
    user = user["data"];
    application = application["data"];

    var apiKey = application["apiKey"];
    currentUser= user;
    currentApp = application;

    var tags = new Map();
    tags['tag1'] = "test tag1";
    tags['tag2'] = "test tag2";
    // httprequest.fields['jsonTags'] = ;

    var response = await uploadArtifact(apiKey,"master","X.Y.Z_prod","prod",jsonField:JSON.encode(tags),artifactName:"rpc/ApkTest.apk" );
    var responseJson = parseResponse(response);
    currentArtifact = responseJson["data"];
    expect(response.statusCode, equals(200));

  });

  test("Retrieve download infos Android", () async {
    var uuid =  currentArtifact["uuid"];
    var artifactdownloadInfoUrl = '/api/art/v1/artifacts/$uuid/download';
    var response = await sendRequest('GET', artifactdownloadInfoUrl);
    expect(response.statusCode, equals(200));
    var responseJson = parseResponse(response);
    responseJson = responseJson["data"];
    var prefix = baseUrlHost;
    var match = prefix.matchAsPrefix(responseJson['directLinkUrl']);
    expect(match,isNotNull);
    expect(responseJson['directLinkUrl'],equals(responseJson['installUrl']));
  });

  //createAndLogin();
  test("Upload artifact OK IOS", () async {
    var user = await loginUser(userInfosSample["email"],userInfosSample["password"]) ;
    var application = await createApplication(infos:applicationCreationiOS);
    user = user["data"];
    application = application["data"];

    var apiKey = application["apiKey"];
    currentUser= user;
    currentApp = application;

    var tags = new Map();
    tags['tag1'] = "test tag1";
    tags['tag2'] = "test tag2";
   // httprequest.fields['jsonTags'] = ;

    var response = await uploadArtifact(apiKey,"master","X.Y.Z_prod","prod",jsonField:JSON.encode(tags),artifactName:"rpc/test.ipa" );
    var responseJson = parseResponse(response);
    currentArtifact = responseJson["data"];
    expect(response.statusCode, equals(200));

  });

  test("Retrieve download infos IOS", () async {
    var uuid =  currentArtifact["uuid"];
    var artifactdownloadInfoUrl = '/api/art/v1/artifacts/$uuid/download';
    var response = await sendRequest('GET', artifactdownloadInfoUrl);
    expect(response.statusCode, equals(200));
    var responseJson = parseResponse(response);
    responseJson = responseJson["data"];
    var prefix = baseUrlHost;
    var match = prefix.matchAsPrefix(responseJson['directLinkUrl']);
    expect(match,isNotNull);
    prefix ='itms-services://?action=download-manifest&url=${Uri.encodeComponent(baseUrlHost)}';
    match = prefix.matchAsPrefix(responseJson['installUrl']);
    expect(match,isNotNull);
  });


  test("delete  artifact OK", () async {
    String artifactId = currentArtifact["uuid"];
    var deleteArtifactUrl = '/api/art/v1/artifacts/${artifactId}';
    var response = await sendRequest('DELETE', deleteArtifactUrl);
    var responseJson = parseResponse(response);
  });

  test("Upload list artifacts OK", () async {
    var apiKey = currentApp["apiKey"];

    var tags = new Map();
    tags['tag1'] = "test tag1";
    tags['tag2'] = "test tag2";
    // httprequest.fields['jsonTags'] = ;
    var artifactsCreated = [];
    for (int i = 0; i<30;i++){
      var response = await uploadArtifact(apiKey,"test","X.Y.${i}_prod","prod",artifactName:"rpc/test.ipa");
      expect(response.statusCode, equals(200));
      var responseJson = parseResponse(response);
      artifactsCreated.add(responseJson["data"]);
    }

    expect(artifactsCreated, isNotEmpty);
  });

  List<Map> allArtifacts = new List<Map>();
  test("Retrieve list artifacts OK", () async {
    await loginUser(userInfosSample["email"],userInfosSample["password"]);
    var appId = currentApp["uuid"];
    var artifactUrl = '/api/applications/v1/app/${appId}/versions?pageIndex=0&limitPerPage=20';
    print('url $artifactUrl');
    var response = await sendRequest('GET', artifactUrl);
    var responseJson = parseResponse(response);
    expect(response.statusCode, equals(200));
    expect(responseJson['list'].length, equals(20));
    allArtifacts.addAll(responseJson['list']);
  });

  test("Delete list artifacts OK", () async {
    for (Map map in allArtifacts){
      String artifactId = map["uuid"];
      var deleteArtifactUrl = '/api/art/v1/artifacts/${artifactId}';
      var response = await sendRequest('DELETE', deleteArtifactUrl);
      var responseJson = parseResponse(response);
      print("response $responseJson");
    }
  });
  test("Retrieve list artifacts Empty OK", () async {
    var appId = currentApp["uuid"];
    var artifactUrl = '/api/applications/v1/app/${appId}/versions?pageIndex=0&limitPerPage=20';
    print('url $artifactUrl');
    var response = await sendRequest('GET', artifactUrl);
    var responseJson = parseResponse(response);
    expect(response.statusCode, equals(200));
    expect(responseJson['list'].length, equals(10));
    allArtifacts.clear();
    allArtifacts.addAll(responseJson['list']);
  });


}