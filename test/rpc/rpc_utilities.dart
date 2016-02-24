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
import '../../server/managers/managers.dart' as mgrs;

var baseAppUri = "/api/applications/v1";

var userInfosSample = {"email":"test@test.com", "password":"passwd", "name":"toto"};
var applicationCreationiOS = {"name":"Application test ios", "description":"Full app description", "platform":"ios"};

Future<Map> registerUser(Map userInfos,{bool mustSuccessful:true}) async{
  var response = await sendRequest('POST', '/api/users/v1/register', body: JSON.encode(userInfos));
  if (mustSuccessful){
    expect(response.statusCode, equals(200));
    var responseJson = parseResponse(response);
  }else {
    expect(response.statusCode, equals(400));
  }
  return  parseResponse(response);
}

Future<Map> loginUser(String login, String password, {bool mustSuccessful:true}) async {
  var response =  await sendRequest('POST', '/api/users/v1/login', body:'username=${login}&password=${password}', contentType:'application/x-www-form-urlencoded');
  var responseJson = parseResponse(response);
  if (mustSuccessful) {
    expect(response.statusCode, equals(200));
  } else {
    expect(response.statusCode, equals(401));
  }
  return  parseResponse(response);
}

Future<Map> createAndLoginUser() async {
  await registerUser(userInfosSample,mustSuccessful:true);
  return loginUser(userInfosSample["email"],userInfosSample["password"]);
}

Future<Map> createApplication({Map infos}) async {
  var appJsonInfos = applicationCreationiOS;
  if (infos != null){
    appJsonInfos = infos;
  }
  var appInfos = new Map.from(appJsonInfos);

  var response = await sendRequest('POST', '${baseAppUri}/create', body: JSON.encode(appInfos));
  var responseJson = parseResponse(response);
  expect(response.statusCode, equals(200));

  return responseJson;
}