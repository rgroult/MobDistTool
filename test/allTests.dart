import "all_core_tests.dart" as core;
import "all_rpc_tests.dart" as rpc;
import '../server/config/src/mongo.dart' as mongo;
import '../server/config/config.dart' as config;
import 'package:objectory/objectory_console.dart';
import 'package:test/test.dart';

void main() {
  test("init ", () async {
      config.loadConfig();
     await mongo.initialize();
  });
  test ("Clean database", ()async {
    await objectory.dropCollections();
  });
  core.allTests();
  test ("Clean database", ()async {
    await objectory.dropCollections();
  });
  rpc.allTests();

  test("close database", () {
    mongo.close();
  });
}