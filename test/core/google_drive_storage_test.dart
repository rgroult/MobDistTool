// Copyright (c) 2016, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'dart:async';
import 'dart:io';
import '../../server/managers/managers.dart' as mdt_mgr;
import '../../server/managers/src/storage/google_drive_manager.dart' as gdrive;

void main() {
  var storage;
  test("init storage", () async {
    storage= new gdrive.GoogleDriveStorageManager();
    await storage.initializeStorage(null);
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
    var stream = await storage.getStreamFromStoredFile(storedFileID);
    //File file = await storage.storageFile(storedFileID);
    expect(stream.toString(),isNotNull);
    print("$stream");
    // api.files.get(objectId).then((drive.File file) {
  });
}