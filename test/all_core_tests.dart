import 'package:test/test.dart';
import 'dart:async';
import 'core/apps_manager_test.dart' as app_test;
import 'core/users_manager_test.dart' as user_test;
import 'core/artifacts_manager_test.dart' as artifact_test;
import '../server/config/src/mongo.dart' as mongo;
import '../server/config/config.dart' as config;
import '../server/config/src/storage.dart' as storage;

void main() {
   test("init", () async {
      await config.loadConfig();
      var value = await mongo.initialize(dropCollectionOnStartup:true);
      await storage.initialize();
   });

   allTests();

   test("close database", () {
      mongo.close();
   });
}

void allTests(){
   user_test.allTests();
   app_test.allTests();
   artifact_test.allTests();
}