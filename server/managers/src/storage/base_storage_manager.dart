// Copyright (c) 2016, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import '../../errors.dart';

class BaseStorageManager {
  String storageIdentifier = "BaseStorageManager";

  String generateStorageInfos(String storageId){
    return "${storageIdentifier}://$storageId";
  }

  String extractStorageId(String storageInfo){
    var regexp = new RegExp('^${storageIdentifier}://(.+)');
    var match = regexp.matchAsPrefix(storageInfo);
    if (match == null){
      throw new ArtifactError('Storage unable to handle this Url');
    }
    return match[1];
  }

  Future initializeStorage(Map config)async{

  }

  Future<String> storeFile(File file, {String appName, String version, String filename, String contentType}) async {
    throw new ArtifactError('Not implemented');
  }

  Future<Stream> getStreamFromStoredFile(String storedInfos) async{
    throw new ArtifactError('Not implemented');
  }

  Future<bool> deleteStoredFile(String storedInfos) async{
    throw new ArtifactError('Not implemented');
  }

  Future<Uri> storageUrI(String infos)async {
    throw new ArtifactError('Not implemented');
  }
}
