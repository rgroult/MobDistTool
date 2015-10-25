import 'dart:async';
import 'package:test/test.dart';
import 'dart:io';
import '../bin/server.dart' as server;
import 'rpc_commons.dart';
import '../server/managers/managers.dart' as mgrs;
import '../server/config/src/mongo.dart' as mongo;

void main()  {
  //start server
  HttpServer httpServer = null;

  test("start server", () async {
    httpServer =  await server.startServer();
  });

/*  test("init database", () async {
    var value = await mongo.initialize();
  });*/

  test("configure values", () async {
    baseUrlHost = "http://${httpServer.address.host}:${httpServer.port}";
    print('baseUrlHost : $baseUrlHost');
  });

  test("Authent KO", () async {
    var response =  await sendRequest('POST','/api/users/v1/login',body:'login=toto&password=titi');
    expect(response.statusCode, equals(401));
  });

  var email = 'test@test.com';
  var adminEmail = 'admin@test.com';
  var password = 'password';
  var adminName = 'user name asdmin';
  var name = 'user name ';
  test("Authent OK", () async {
    //create admin user
    var admin =  await mgrs.createUser(name, email, password);
    expect(admin, isNotNull);
    //create test user
    var test =  await mgrs.createUser(adminName, adminName, password);
    expect(test, isNotNull);

    var user =  await mgrs.findUserByEmail(email);
    //test authent
    var response =  await sendRequest('POST','/api/users/v1/login',body:'login=$adminEmail&password=$password');
    expect(response,isNotNull);
    print("response ${response.body}");
  });

  test("all rpc tests", () async {
    print('all RPC tests');
  });


  test("stop server", () async {
   // HttpApiResponse response = await _sendRequest('GET', 'get/simple');
    var result =  httpServer.close(force:true);
  });
}