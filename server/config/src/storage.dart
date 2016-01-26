import 'dart:async';
import '../../managers/src/storage/yes_storage_manager.dart';
import '../../managers/src/storage/google_drive_manager.dart';
import '../../managers/src/artifacts_manager.dart' as mgr;
import '../config.dart' as config;

Future initialize() async{
  var storage = config.currentLoadedConfig[config.MDT_STORAGE_NAME];
  switch (storage){
    case "google_drive_manager":
      print("Storage initialized to Google Drive Manager");
      mgr.defaultStorage = new GoogleDriveStorageManager();
      break;
    case "yes_storage_manager":
      mgr.defaultStorage = new YesStorageManager();
      print("Storage initialized to Yes Storage Manager");
      break;
    default:
      throw new StateError("Invalid storage name $storage");
  }
  await mgr.defaultStorage.initializeStorage(config.currentLoadedConfig[config.MDT_STORAGE_CONFIG]);
}