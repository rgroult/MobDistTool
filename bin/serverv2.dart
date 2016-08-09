import 'dart:async';
import 'dart:io';
import 'package:redstone/redstone.dart' as app;
import 'package:shelf_static/shelf_static.dart' as shelf_static;
import '../server/config/config.dart' as config;
import '../server/utils/utils.dart' as utils;
import '../web/version.dart' as version;

//static http server instance (usefull for unit test)
HttpServer httpServer;

Future<HttpServer> startServer({bool resetDatabaseContent:false}) async {
  await config.loadConfig();

  //Add static handler for UI files
  app.setShelfHandler(shelf_static.createStaticHandler('web',
      defaultDocument: 'index.html'));

  app.setupConsoleLog();
  var server = app.start(port: config.currentLoadedConfig[config.MDT_SERVER_PORT]);
  server.then((server) {
    utils.printAndLog('MDT version(${version.MDT_VERSION}) started on port ${server.port}.');
    utils.printAndLog('You can access server Web UI on http://localhost:${server.port}/web/');
    httpServer=server;
  });
}

Future main() async{
  await startServer();
  //await userMgr.createSysAdminIfNeeded();

}