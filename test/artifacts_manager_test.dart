import 'package:test/test.dart';
import 'dart:async';
import 'package:objectory/objectory_console.dart';
import '../bin/managers/apps_manager.dart' as app_mgr;
import '../bin/managers/artifacts_manager.dart' as arts_mgr;
import '../bin/config/mongo.dart' as mongo;

void main() {
  test("init database", () async {
    var value = await mongo.initialize();
  });

  allTests();

  test("close database", () async {
    var value = await objectory.close();
  });
}

void allTests()  {
  test("Clean database", () async {
    await objectory.dropCollections();
  });
  var appName = "test";
  var appIOS = "IOS";
  test("Create artifact", () async {
    var app = await app_mgr.createApplication(appName,appIOS);
    expect(app, isNotNull);

    var artifact = await arts_mgr.createArtifact(app,"test","0.1.0",sortIdentifier:"sort 01.10");
  });
}