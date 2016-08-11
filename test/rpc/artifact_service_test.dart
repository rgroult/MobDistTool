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
import '../../server/utils/utils.dart' as utils;
import 'user_service_test.dart';

var baseArtUri = "/api/applications/v1";

void main() {
  //start server
  HttpServer httpServer = null;

  test("start server", () async {
    httpServer = await server.startServer(resetDatabaseContent: true);
  });

  test("configure values", () async {
    baseUrlHost = "http://localhost:${httpServer.port}";
    print('baseUrlHost : $baseUrlHost');
  });

  allTests();

  test("stop server", () async  {
    // HttpApiResponse response = await _sendRequest('GET', 'get/simple');
    await server.stopServer(force:true);
    print('server stopped');
  });
}

var userRegistration1 = {"email":"apptest@test.com", "password":"passwd", "name":"app user 1"};
var userRegistration2 = {"email":"apptest2@test.com", "password":"passwd", "name":"app user 2"};
var applicationCreationiOS = {"name":"Application test ios", "description":"Full app description", "platform":"ios","enableMaxVersionCheck":true};
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

Future<http.Response>  deleteArtifact(String apiKey,String branch,String version, String name, {bool isLatest}) async{
  var artifactUrl = "/api/in/v1/artifacts/${apiKey}/master/$version/$name";
  if (isLatest == true) {
    artifactUrl =  "/api/in/v1/artifacts/${apiKey}/last/$name";
  }
  return await sendRequest('DELETE', artifactUrl);
}

Future<http.Response>  uploadArtifact(String apiKey,String branch,String version, String name,{bool isLatest, String jsonField,String artifactName}) async{
  var uri = Uri.parse("${baseUrlHost}/api/in/v1/artifacts/${apiKey}/master/$version/$name");
  if (isLatest == true) {
    uri = Uri.parse("${baseUrlHost}/api/in/v1/artifacts/${apiKey}/last/$name");
  }
  var httprequest = new http.MultipartRequest('POST',uri);
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

    var response = await uploadArtifact(apiKey,"master","X.Y.Z_prod","prod",jsonField:JSON.encode(tags),artifactName:"../server/managers/src/storage/apk_sample.apk" );
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
    print("$responseJson");
    print("Host : $baseUrlHost");
    var prefix = baseUrlHost;
    var match = prefix.matchAsPrefix(responseJson['directLinkUrl']);
    expect(match,isNotNull);
    expect(responseJson['directLinkUrl'],equals(responseJson['installUrl']));
  });

  test("Delete artifact  Android", () async {
    var apiKey = currentApp["apiKey"];
    var response = await deleteArtifact(apiKey,"master","X.Y.Z_prod","prod");
    var responseJson = parseResponse(response);
    expect(response.statusCode, equals(200));
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

    var response = await uploadArtifact(apiKey,"master","X.Y.Z_prod","prod",jsonField:JSON.encode(tags),artifactName:"../server/managers/src/storage/ipa_sample.ipa" );
    var responseJson = parseResponse(response);
    currentArtifact = responseJson["data"];
    expect(response.statusCode, equals(200));

  });

  test("Upload artifact OK Latest IOS", () async {
    var apiKey = currentApp["apiKey"];
    var response = await uploadArtifact(apiKey,"master","X.Y.Z_prod","prod",isLatest: true, artifactName:"../server/managers/src/storage/ipa_sample.ipa" );
    var responseJson = parseResponse(response);
    print("response: $responseJson");
    expect(response.statusCode, equals(200));

  });

  test("Delete artifact OK Latest IOS", () async {
    var apiKey = currentApp["apiKey"];
    var response = await deleteArtifact(apiKey,"master","X.Y.Z_prod","prod",isLatest: true);
    var responseJson = parseResponse(response);
    expect(response.statusCode, equals(200));
  });

  test("Retrieve download infos IOS and download file", () async {
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

    //manifest
    //extract manifest Url
    var manifestFileUrl = responseJson['installUrl'].replaceFirst("itms-services://?action=download-manifest&url=","");
    manifestFileUrl = Uri.decodeFull(manifestFileUrl);
    var manifestfile =  await http.get(manifestFileUrl);
    expect(manifestfile.statusCode, equals(200));
    expect(manifestfile.headers["content-type"],equals("application/plist"));

    //download file
    var binaryFile = await http.get(responseJson['directLinkUrl']);
    expect(binaryFile.statusCode, equals(200));
    expect(binaryFile.headers["content-type"],equals("application/octet-stream ipa"));
  });


  test("maxVersionCheck enabled KO", () async {
    var uuid = currentApp["uuid"];
    var ts = new DateTime.now().millisecondsSinceEpoch;
    var query = "ts=$ts&branch=toto&hash=toto";
    var url = '/api/applications/v1/app/${uuid}/maxversion/prod?$query';
    var response = await sendRequest('GET', url);
    var responseJson = parseResponse(response);
    expect(response.statusCode, equals(401));
  });

  test("maxVersionCheck enabled OK", () async {
    var secret = currentApp["maxVersionSecretKey"];
    var uuid = currentApp["uuid"];
    var branch =  'master';
    var name = 'prod';
    var ts = new DateTime.now().millisecondsSinceEpoch;
    var stringToHash = "ts=$ts&branch=$branch&hash=${secret}";
    var hash = utils.generateHash(stringToHash);
    var query = "ts=$ts&branch=$branch&hash=${hash}";
    var url = '/api/applications/v1/app/${uuid}/maxversion/$name?$query';
    var response = await sendRequest('GET', url);
    var responseJson = parseResponse(response);
    expect(response.statusCode, equals(200));
    responseJson = responseJson["data"];
    expect(responseJson["branch"], equals(branch));
    expect(responseJson["name"], equals(name));
    expect(responseJson["version"], equals(currentArtifact["version"]));
  });

  test ("maxVersionCheck enabled after new version OK",() async {
    //await createAndLoginUser();
    var application = currentApp;
    var apiKey = application["apiKey"];
    var newVersion = 'Y.Y.Z_prod';
    var response = await uploadArtifact(apiKey,"master",newVersion,"prod",artifactName:"../server/managers/src/storage/ipa_sample.ipa" );
    var responseJson = parseResponse(response);
    currentArtifact = responseJson["data"];
    expect(response.statusCode, equals(200));

    var secret = currentApp["maxVersionSecretKey"];
    var uuid = currentApp["uuid"];
    var branch =  'master';
    var name = 'prod';
    var ts = new DateTime.now().millisecondsSinceEpoch;
    var stringToHash = "ts=$ts&branch=$branch&hash=${secret}";
    var hash = utils.generateHash(stringToHash);
    var query = "ts=$ts&branch=$branch&hash=${hash}";
    var url = '/api/applications/v1/app/${uuid}/maxversion/$name?$query';
    response = await sendRequest('GET', url);
    responseJson = parseResponse(response);
    expect(response.statusCode, equals(200));
    responseJson = responseJson["data"];
    expect(responseJson["branch"], equals(branch));
    expect(responseJson["name"], equals(name));
    expect(responseJson["version"], equals(newVersion));
  });

  test("delete  artifact OK", () async {
    await loginUser(userInfosSample["email"],userInfosSample["password"]) ;
    String artifactId = currentArtifact["uuid"];
    var deleteArtifactUrl = '/api/art/v1/artifacts/${artifactId}';
    var response = await sendRequest('DELETE', deleteArtifactUrl);
    var responseJson = parseResponse(response);
    expect(response.statusCode, equals(200));
  });


  test("Upload list artifacts OK", () async {
    var apiKey = currentApp["apiKey"];

    var tags = new Map();
    tags['tag1'] = "test tag1";
    tags['tag2'] = "test tag2";
    // httprequest.fields['jsonTags'] = ;
    var artifactsCreated = [];
    for (int i = 0; i<30;i++){
      var response = await uploadArtifact(apiKey,"test","X.Y.${i}_prod","prod",artifactName:"../server/managers/src/storage/ipa_sample.ipa");
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
    expect(responseJson['list'].length, equals(11));
    allArtifacts.clear();
    allArtifacts.addAll(responseJson['list']);
  });


}