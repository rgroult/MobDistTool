import 'package:test/test.dart';
import 'dart:async';
import 'dart:io';
import '../../server/managers/managers.dart' as mdt_mgr;
import '../../server/managers/src/storage/google_drive_manager.dart' as gdrive;

void main() {
  var storage;
  test("init storage", () async {
    storage= new gdrive.GoogleDriveStorageManager();
    await storage.initializeStorage();
  });
  var storedFileID=null;

  test("upload file", () async {
    print("current ${Directory.current}");
    var result = await storage.storeFile (new File("test/core/artifact_sample.txt"));
    expect(result,isNotNull);
    storedFileID = result;
    print("$result");
  });

  test("download file", () async {
    expect(storedFileID,isNotNull);
    File file = await storage.storageFile(storedFileID);
    expect(file,isNotNull);
    print("$file");
    // api.files.get(objectId).then((drive.File file) {
  });
}