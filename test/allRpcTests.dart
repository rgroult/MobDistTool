import 'dart:async';
import 'package:test/test.dart';
import 'dart:io';
import '../bin/server.dart' as server;
import 'rpc_commons.dart';

void main()  {
  //start server
  HttpServer httpServer = null;

  test("start server", () async {
    httpServer =  await server.startServer();
  });

  test("configure values", () async {
    baseUrlHost = "http://${httpServer.address.host}:${httpServer.port}";
    print('baseUrlHost : $baseUrlHost');
  });

test("Authent KO", () async {
    var response =  await sendRequest('POST','/api/users/v1/login',body:'login=toto&password=titi');
    expect(response.statusCode, equals(401));
    //print('response : $response');
  });

  test("start server", () async {
    print('all RPC tests');
  });


  test("stop server", () async {
   // HttpApiResponse response = await _sendRequest('GET', 'get/simple');
    var result =  httpServer.close(force:true);
  });
}