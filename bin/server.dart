// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart';
import 'package:rpc/rpc.dart';
import 'package:shelf_rpc/shelf_rpc.dart' as shelf_rpc;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'config/mongo.dart' as mongo;

//import 'package:rpc-examples/toyapi.dart';
import 'model/model.dart';

import 'user_authentication_service.dart';

const _API_PREFIX = '/api';
final ApiServer _apiServer =
new ApiServer(apiPrefix: _API_PREFIX, prettyPrint: true);

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
  _apiServer.enableDiscoveryApi();

  // Create a Shelf handler for your RPC API.
  var apiHandler = shelf_rpc.createRpcHandler(_apiServer);

  var apiRouter = shelf_route.router();
  apiRouter.add(_API_PREFIX, null, apiHandler, exactMatch: false);
  var handler = const shelf.Pipeline()
  .addMiddleware(shelf.logRequests())
  .addHandler(apiRouter.handler);

  var server = await shelf_io.serve(handler, '0.0.0.0', 8080);
  print('Listening at port ${server.port}.');
}
