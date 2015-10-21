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
import 'config/mongo.dart' as mongo;

//import 'package:rpc-examples/toyapi.dart';
import 'model/model.dart';

import 'user_authentication_service.dart';
import 'application_service.dart';

const _API_PREFIX = '/api';
const _SIGNED_PREFIX = _API_PREFIX+'/in';
const _AUTHORIZED_PREFIX = _API_PREFIX;
const _LOGIN_PREFIX = _API_PREFIX+'/users';

final ApiServer _apiServer = new ApiServer(apiPrefix: _API_PREFIX, prettyPrint: true);
//final ApiServer _statelessApiServer = new ApiServer(apiPrefix: _STATELESS_PREFIX, prettyPrint: true);

Future main() async {
  // Add a simple log handler to log information to a server side file.
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(new SyncFileLoggingHandler('myLogFile.txt'));
  if (stdout.hasTerminal) {
    Logger.root.onRecord.listen(new LogPrintHandler());
  }
  mongo.initialize();

  //_apiServer.addApi(new ToyApi());
  _apiServer.addApi(new UserAuthenticationService());
  _apiServer.addApi(new ApplicationService());
  _apiServer.enableDiscoveryApi();

  //authentication
  var loginMiddleware = authenticate([new UsernamePasswordAuthenticator(authenticateUser)],
  sessionHandler: new JwtSessionHandler('MobDistTool', 'qsdqfsdvdf secret', usernameLookup), allowHttp: true);

  var authenticatedMiddleware = authenticate([new AuthenticatedOnlyAuthoriser()]);
/*
  //login handler
  var loginApiHandler = shelf_rpc.createRpcHandler(_apiServer);
  //signed request handler, used for provisionning artifacts
  var signedRequestApiHandler = shelf_rpc.createRpcHandler(_apiServer);
  //Others routes, authorized by session or auth token
  var authorizedApiHandler = shelf_rpc.createRpcHandler(_apiServer);
*/

  // Create a Shelf handler for your RPC API.
  var apiHandler = shelf_rpc.createRpcHandler(_apiServer);

  var apiRouter = shelf_route.router()
      ..add('api/users',['GET','POST'],apiHandler,exactMatch: false,middleware: loginMiddleware)
      ..add(_SIGNED_PREFIX,null,apiHandler,exactMatch: false,middleware:authenticatedMiddleware)
      ..add(_AUTHORIZED_PREFIX,null,apiHandler,exactMatch: false);


    /*  ..add(_STATELESS_PREFIX, null,apiHandler,exactMatch: false)
      ..add(_API_PREFIX, null, apiHandler, exactMatch: false,middleware: loginMiddleware);*/

  //apiRouter.add(_API_PREFIX, null, apiHandler, exactMatch: false);
  var handler = const shelf.Pipeline()
      .addMiddleware(exceptionHandler())
      .addMiddleware(shelf.logRequests())
      .addHandler(apiRouter.handler);

  var server = await shelf_io.serve(handler, '0.0.0.0', 8080);
  print('Listening at port ${server.port}.');
}


/// Stub implementation
///
/*
lookupByUsernamePassword(String username, String password) async =>
new Future.value(new Option(new Principal(username)));*/
/// Stub implementation
usernameLookup(String username) async =>
new Future.value(new Option(new Principal(username)));
