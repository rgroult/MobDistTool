// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:option/option.dart';
//logging
import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart';
//rpc
import 'package:rpc/rpc.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_rpc/shelf_rpc.dart' as shelf_rpc;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_exception_handler/shelf_exception_handler.dart';
//authentication / authorisation
import 'package:shelf_auth/shelf_auth.dart';
import 'package:shelf_auth/src/authorisers/authenticated_only_authoriser.dart';

//server
import 'package:shelf/shelf_io.dart' as shelf_io;
//mongo DB
import '../server/config/src/mongo.dart' as mongo;
//API
import '../server/managers/managers.dart';

//import 'package:rpc-examples/toyapi.dart';
//import '../server/model';

import '../server/services/user_service.dart';
import '../server/services/application_service.dart';
import '../server/services/artifact_service.dart';

const _API_PREFIX = '/api';
const _SIGNED_PREFIX = _API_PREFIX+'/in';
const _AUTHORIZED_PREFIX = _API_PREFIX;
const _LOGIN_PREFIX = _API_PREFIX+'/users';

final ApiServer _apiServer = new ApiServer(apiPrefix: _API_PREFIX, prettyPrint: true);
//final ApiServer _statelessApiServer = new ApiServer(apiPrefix: _STATELESS_PREFIX, prettyPrint: true);

HttpServer httpServer;

Future stopServer({bool force:false}) async {
  await httpServer.close(force:true);
}

Future<HttpServer> startServer({bool resetDatabaseContent:false}) async {
  // Add a simple log handler to log information to a server side file.
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(new SyncFileLoggingHandler('myLogFile.txt'));
  if (stdout.hasTerminal) {
    Logger.root.onRecord.listen(new LogPrintHandler());
  }
  await mongo.initialize(dropCollectionOnStartup:resetDatabaseContent);

  //_apiServer.addApi(new ToyApi());
  _apiServer.addApi(new UserService());
  _apiServer.addApi(new ApplicationService());
  _apiServer.addApi(new ArtifactService());
  _apiServer.enableDiscoveryApi();

  //authentication
  var sessionHandler = new JwtSessionHandler('MobDistTool', 'qsdqfsdvdf secret', usernameLookup);
  var loginMiddleware = authenticate([new UsernamePasswordAuthenticator(authenticateUser)],
  sessionHandler:sessionHandler , allowHttp: true);

  var defaultAuthMiddleware = authenticate([],
  sessionHandler: sessionHandler, allowHttp: true,
  allowAnonymousAccess: false);

  var authenticatedMiddleware = authorise([new AuthenticatedOnlyAuthoriser()]);

  // Create a Shelf handler for your RPC API.
  var apiHandler = shelf_rpc.createRpcHandler(_apiServer);

  var apiRouter = shelf_route.router()
      //disable authent for register
      ..add('api/users/v1/register',null,apiHandler,exactMatch: false)
      ..add('/api/art/',null,apiHandler,exactMatch: false)
      ..add('api/users',['GET','POST'],apiHandler,exactMatch: false,middleware: loginMiddleware)
      ..add(_SIGNED_PREFIX,null,apiHandler,exactMatch: false,middleware:authenticatedMiddleware)
      //disable authent for discovery ?
      ..add('api/discovery',null,apiHandler,exactMatch: false)

      ..add('api/',null,apiHandler,exactMatch: false,middleware:defaultAuthMiddleware);

  var handler = const shelf.Pipeline()
      .addMiddleware(exceptionHandler())
      .addMiddleware(shelf.logRequests())
      .addHandler(apiRouter.handler);

  var server =  shelf_io.serve(handler, '0.0.0.0', 8080);
  server.then((server) { print('Listening at port ${server.port}.');httpServer=server;});
//  print('Listening at port ${await server.port}.');


  return new Future.value(server);
  //return server;
  //return new Future(server;
}

Future main() async{
  var server = await startServer();
}


/// Stub implementation
///
/*
lookupByUsernamePassword(String username, String password) async =>
new Future.value(new Option(new Principal(username)));*/
/// Stub implementation
/*
usernameLookup(String username) async =>
new Future.value(new Option(new Principal(username)));
*/