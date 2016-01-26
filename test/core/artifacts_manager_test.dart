import 'package:test/test.dart';
import 'dart:async';
import 'dart:io';
import 'package:objectory/objectory_console.dart';
import '../../server/managers/managers.dart' as mdt_mgr;
import '../../server/config/src/mongo.dart' as mongo;
import '../../server/config/config.dart' as config;

void main() {
  test("init database", () async {
    config.loadConfig();
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

    var artifact = await mdt_mgr.createArtifact(app,"test","0.1.0","branch",sortIdentifier:"sort 01.10");
    expect(artifact,isNotNull);
    expect(artifact.storageInfos,isNull);
    await mdt_mgr.addFileToArtifact(new File(Directory.current.path+'/test/core/artifact_sample.txt'),artifact,mdt_mgr.defaultStorage);
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
    var stream = await mdt_mgr.streamFromArtifact(artifact,mdt_mgr.defaultStorage);
    var content = stream.toString();
    //var file = await mdt_mgr.fileFromArtifact(artifact,mdt_mgr.defaultStorage);
    //var content = await (file.readAsString());
    expect(content,isNotNull);

    /* not supported yet
    var uri = await mdt_mgr.uriFromArtifact(artifact,mdt_mgr.defaultStorage);
    expect(uri, ArtifactError);*/

    //file = new File.fromUri(uri);
     //content = await HttpRequest.getString(uri);
    //content = await (file.readAsString());
    /* TO DO : Read content of file */
    //expect(uri,isNotNull);
  });

  test("Delete artifact File", () async {
    var app = await mdt_mgr.findApplication(appName,appIOS);
    var allArtifact = await mdt_mgr.findAllArtifacts(app);
    var artifact = allArtifact.first;
    expect(artifact.storageInfos,isNotNull);
    await mdt_mgr.deleteArtifactFile(artifact,mdt_mgr.defaultStorage);
    expect(artifact.storageInfos,isNull);

    await mdt_mgr.deleteArtifact(artifact,mdt_mgr.defaultStorage);
    allArtifact = await mdt_mgr.findAllArtifacts(app);
    expect(allArtifact.length,equals(0));
  });

  test("search artifacts", () async {
    var app = await  mdt_mgr.findApplication(appName,appIOS);
    //add artifacts
    var artifactsCreated = [];
    for (int i = 0; i<30;i++){
      artifactsCreated.add(await mdt_mgr.createArtifact(app,"test","version 0.0.$i","master"));
    }

    //search artifacts
    List artifacts = await mdt_mgr.searchArtifacts(app, pageIndex:1,branch:"develop");
    expect(artifacts.length,equals(0));

    artifacts = await mdt_mgr.searchArtifacts(app, pageIndex:1,branch:"master",limitPerPage:20);
    expect(artifacts,isNotNull);
    expect(artifacts.length,equals(20));

    artifacts = await mdt_mgr.searchArtifacts(app, pageIndex:2,branch:"master",limitPerPage:20);
    expect(artifacts.length,equals(10));
    var artifact = artifacts.first;
    expect(artifact.version,equals("version 0.0.9"));
  });

  test("Delete artifact", () async {
    var app = await mdt_mgr.createApplication(appName,appAndroid);

    var artifact = await mdt_mgr.createArtifact(app,"test","0.1.0","master",sortIdentifier:"sort 01.10");
    var allArtifact = await mdt_mgr.findAllArtifacts(app);
    expect(allArtifact.length,equals(1));

    await mdt_mgr.deleteAllArtifacts(app,mdt_mgr.defaultStorage);
    allArtifact = await mdt_mgr.findAllArtifacts(app);
    expect(allArtifact.length,equals(0));
  });
}