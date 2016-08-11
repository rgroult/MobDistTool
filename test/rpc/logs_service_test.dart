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
import '../../server/config/config.dart' as config;
import '../../server/managers/managers.dart' as mgrs;

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
  test("Create sysadmin", () async {
    await mgrs.createSysAdminIfNeeded();
  });

  test("Authent Admin OK", () async {
    await loginTest(config.currentLoadedConfig[config.MDT_SYSADMIN_INITIAL_EMAIL],config.currentLoadedConfig[config.MDT_SYSADMIN_INITIAL_PASSWORD], mustSuccessful:true, name:"admin");
  });

  test("console Log", () async {
    var response = await sendRequest('GET','/api/logs/v1/tail/console');
    var responseJson = parseResponse(response);
   // print("$responseJson");
    expect(response.statusCode, equals(200));
    expect(responseJson["data"], isNotNull);
  });

  test("activity Log", () async {
    var response = await sendRequest('GET','/api/logs/v1/tail/activity');
    expect(response.statusCode, equals(200));
    var responseJson = parseResponse(response);
    expect(responseJson["data"], isNotNull);
  });
}