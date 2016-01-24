import 'dart:async';
import 'dart:io';
import 'package:googleapis_auth/auth_browser.dart' as auth;
import 'package:googleapis/drive/v2.dart' as drive;
import '../artifacts_manager.dart';
import '../../errors.dart';

class GoogleDriveStorageManager extends BaseStorageManager {
  GoogleDriveStorageManager(){
  }

  bool canHandleStorageUrl(){
    throw new ArtifactError('Not implemented');
    return false;
  }

  Future<Uri> storageUrI(String infos) {
    throw new ArtifactError('Not implemented');
  }

  Future<File> storageFile(String infos) {
    throw new ArtifactError('Not implemented');
  }

  Future<String> storeFile(File file) {
    throw new ArtifactError('Not implemented');
  }

  Future<bool> deleteFile(File file) {
    throw new ArtifactError('Not implemented');
  }

  Future<bool> deleteFileFromInfos(String infos) {
    throw new ArtifactError('Not implemented');
  }
