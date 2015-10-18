import 'package:test/test.dart';
import 'dart:async';
import 'dart:io';
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
  var appAndroid = "Android";
  test("Create artifact", () async {
    var app = await app_mgr.createApplication(appName,appIOS);
    expect(app, isNotNull);

    var artifact = await arts_mgr.createArtifact(app,"test","0.1.0",sortIdentifier:"sort 01.10");
    expect(artifact,isNotNull);
    expect(artifact.storageInfos,isNull);
    await arts_mgr.addFileToArtifact(new File("artifact_sample.txt"),artifact,arts_mgr.defaultStorage);
    expect(artifact.storageInfos,isNotNull);
    expect(artifact.version,equals("0.1.0"));
    expect(artifact.name,equals("test"));
    expect(artifact.sortIdentifier,equals("sort 01.10"));
    expect(artifact.application,equals(app));
  });

  test("Find artifact", () async {
    var allArtifact = await arts_mgr.allArtifacts();
    expect(allArtifact.length,equals(1));

    var app = await app_mgr.findApplication(appName,appIOS);
    allArtifact = await arts_mgr.findAllArtifacts(app);
    expect(allArtifact.length,equals(1));

    /* TO DO
    var artifact = allArtifact.first;
    var art = await arts_mgr.findArtifact(artifact.uuid);
    expect(artifact.uuid,equals(art.uuid));
    */

  });

  test("Delete artifact", () async {
    var app = await app_mgr.findApplication(appName,appIOS);
    var allArtifact = await arts_mgr.findAllArtifacts(app);
    var artifact = allArtifact.first;
    expect(artifact.storageInfos,isNotNull);
    await arts_mgr.deleteArtifactFile(artifact,arts_mgr.defaultStorage);
    expect(artifact.storageInfos,isNull);

    await arts_mgr.deleteArtifact(artifact,arts_mgr.defaultStorage);
    allArtifact = await arts_mgr.findAllArtifacts(app);
    expect(allArtifact.length,equals(0));

    artifact = await arts_mgr.createArtifact(app,"test","0.1.0",sortIdentifier:"sort 01.10");
    allArtifact = await arts_mgr.findAllArtifacts(app);
    expect(allArtifact.length,equals(1));

    await arts_mgr.deleteAllArtifacts(app,arts_mgr.defaultStorage);
    allArtifact = await arts_mgr.findAllArtifacts(app);
    expect(allArtifact.length,equals(0));

  });
}