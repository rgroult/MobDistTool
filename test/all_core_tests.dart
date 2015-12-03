import 'package:test/test.dart';
import 'dart:async';
import 'core/apps_manager_test.dart' as app_test;
import 'core/users_manager_test.dart' as user_test;
import 'core/artifacts_manager_test.dart' as artifact_test;
import '../server/config/src/mongo.dart' as mongo;

void main() {
   test("init database", () async {
      var value = await mongo.initialize();
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