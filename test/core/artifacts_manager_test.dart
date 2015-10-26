import 'package:test/test.dart';
import 'dart:async';
import 'dart:io';
import 'package:objectory/objectory_console.dart';
import '../../server/managers/managers.dart' as mdt_mgr;
import '../../server/config/src/mongo.dart' as mongo;

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
    var app = await mdt_mgr.createApplication(appName,appIOS);
    expect(app, isNotNull);

    var artifact = await mdt_mgr.createArtifact(app,"test","0.1.0",sortIdentifier:"sort 01.10");
    expect(artifact,isNotNull);
    expect(artifact.storageInfos,isNull);
    await mdt_mgr.addFileToArtifact(new File("artifact_sample.txt"),artifact,mdt_mgr.defaultStorage);
    expect(artifact.storageInfos,isNotNull);
    expect(artifact.version,equals("0.1.0"));
    expect(artifact.name,equals("test"));
    expect(artifact.sortIdentifier,equals("sort 01.10"));
    expect(artifact.application,equals(app));
  });

  test("Find artifact", () async {
    var allArtifact = await mdt_mgr.allArtifacts();
    expect(allArtifact.length,equals(1));

    var app = await mdt_mgr.findApplication(appName,appIOS);
    allArtifact = await mdt_mgr.findAllArtifacts(app);
    expect(allArtifact.length,equals(1));

    /* TO DO
    var artifact = allArtifact.first;
    var art = await arts_mgr.findArtifact(artifact.uuid);
    expect(artifact.uuid,equals(art.uuid));
    */

  });

  test("retrieve file artifact", () async {
    var allArtifact = await mdt_mgr.allArtifacts();
    var artifact = allArtifact.first;
    var file = await mdt_mgr.fileFromArtifact(artifact,mdt_mgr.defaultStorage);
    var content = await (file.readAsString());
    expect(content,isNotNull);

    var uri = await mdt_mgr.uriFromArtifact(artifact,mdt_mgr.defaultStorage);
    //file = new File.fromUri(uri);
     //content = await HttpRequest.getString(uri);
    //content = await (file.readAsString());
    /* TO DO : Read content of file */
    expect(uri,isNotNull);
  });

  test("Delete artifact", () async {
    var app = await mdt_mgr.findApplication(appName,appIOS);
    var allArtifact = await mdt_mgr.findAllArtifacts(app);
    var artifact = allArtifact.first;
    expect(artifact.storageInfos,isNotNull);
    await mdt_mgr.deleteArtifactFile(artifact,mdt_mgr.defaultStorage);
    expect(artifact.storageInfos,isNull);

    await mdt_mgr.deleteArtifact(artifact,mdt_mgr.defaultStorage);
    allArtifact = await mdt_mgr.findAllArtifacts(app);
    expect(allArtifact.length,equals(0));

    artifact = await mdt_mgr.createArtifact(app,"test","0.1.0",sortIdentifier:"sort 01.10");
    allArtifact = await mdt_mgr.findAllArtifacts(app);
    expect(allArtifact.length,equals(1));

    await mdt_mgr.deleteAllArtifacts(app,mdt_mgr.defaultStorage);
    allArtifact = await mdt_mgr.findAllArtifacts(app);
    expect(allArtifact.length,equals(0));

  });
}