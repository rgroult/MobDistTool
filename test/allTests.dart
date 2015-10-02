import 'dart:async';
import 'apps_manager_test.dart' as app_test;
import 'users_manager_test.dart' as user_test;
import '../bin/config/mongo.dart' as mongo;

 Future main() async {
    await mongo.initialize();
    await user_test.allTests();
    print("users tests done!");
    await app_test.allTests();
    print("apps tests done!");
}