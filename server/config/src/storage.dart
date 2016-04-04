// Copyright (c) 2016, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:async';
import '../../managers/src/storage/yes_storage_manager.dart';
import '../../managers/src/storage/google_drive_manager.dart';
import '../../managers/src/storage/local_storage_manager.dart';
import '../../managers/src/artifacts_manager.dart' as mgr;
import '../config.dart' as config;
import '../../utils/utils.dart';

Future initialize() async{
  var storage = config.currentLoadedConfig[config.MDT_STORAGE_NAME];
  switch (storage){
    case "google_drive_manager":
      printAndLog("Storage initialized to Google Drive Manager");
      mgr.defaultStorage = new GoogleDriveStorageManager();
      break;
    case "yes_storage_manager":
      mgr.defaultStorage = new YesStorageManager();
      printAndLog("Storage initialized to Yes Storage Manager");
      break;
    case "local_storage_manager":
      mgr.defaultStorage = new LocalStorageManager();
      printAndLog("Storage initialized to Local Storage Manager");
      break;
    default:
      throw new StateError("Invalid storage name $storage");
  }
  await mgr.defaultStorage.initializeStorage(config.currentLoadedConfig[config.MDT_STORAGE_CONFIG]);
}