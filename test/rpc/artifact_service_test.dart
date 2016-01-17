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

  test("start server", () async {
    httpServer = await server.startServer();
  });

  test("configure values", () async {
    baseUrlHost = "http://${httpServer.address.host}:${httpServer.port}";
    print('baseUrlHost : $baseUrlHost');
  });


  allTests();
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

void updloadArtifact(Map app,dynamic filePart,String branch,String version, String name,{String jsonField}){

}

void allTests() {
  //createAndLogin();
  test("Upload artifact OK", () async {
    var user = await createAndLoginUser();
    var application = await createApplication();
    user = user["data"];
    application = application["data"];

    var apiKey = application["apiKey"];

    var httprequest = new http.MultipartRequest('POST',Uri.parse("${baseUrlHost}/api/art/v1/artifacts/${apiKey}/master/versionBeta/prodArtifact"));
    var filePart = await http.MultipartFile.fromPath('artifactFile', Directory.current.path+'/test/core/artifact_sample.txt');
    httprequest.files.add(filePart);
    httprequest.fields['sortIdentifier'] = 'sortId';
    var tags = new Map();
    tags['tag1'] = "test tag1";
    tags['tag2'] = "test tag2";
    httprequest.fields['jsonTags'] = JSON.encode(tags);

    var response = await http.Response.fromStream(await httprequest.send());
    var responseJson = parseResponse(response);
    expect(response.statusCode, equals(200));
/*
    final FormData formdata = new FormData();
    FormData.append('file',new File("../core/artifact_sample.txt"));
    httprequest.send(formdata);*/
  });



}