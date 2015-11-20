import 'dart:async';
import 'dart:core';
import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';
import 'rpc/user_service_test.dart' as users;
import 'rpc/app_service_test.dart' as apps;
import 'rpc/rpc_commons.dart';
import '../bin/server.dart' as server;

void main()  {

  //start server
  HttpServer httpServer = null;

  test("start server", () async {
    httpServer =  await server.startServer();
  });

  test ("Clean database", ()async {
    await objectory.dropCollections();
  });

  test("configure values", () async {
    baseUrlHost = "http://${httpServer.address.host}:${httpServer.port}";
    print('baseUrlHost : $baseUrlHost');
  });

  users.allTests();
  apps.allTests();

/*
  test("stop server", () async {
   // HttpApiResponse response = await _sendRequest('GET', 'get/simple');
    var result =  httpServer.close(force:true);
  });*/
}