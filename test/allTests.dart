import 'package:test/test.dart';
import 'dart:async';
import 'package:objectory/objectory_console.dart';
import 'apps_manager_test.dart' as app_test;
import 'users_manager_test.dart' as user_test;
import 'artifacts_manager_test.dart' as artifact_test;
import '../server/config/src/mongo.dart' as mongo;

void main() {
   test("init database", () async {
      var value = await mongo.initialize();
   });

   user_test.allTests();
   app_test.allTests();
   artifact_test.allTests();

   test("close database", () async {
      var value = await objectory.close();
   });
}