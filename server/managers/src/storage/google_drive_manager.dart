// Copyright (c) 2016, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' show Client;
import 'package:googleapis_auth/auth_io.dart' as auth;
//import 'package:googleapis/common/common.dart' show Media, DownloadOptions;
import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' show Media, DownloadOptions;
import 'package:googleapis/drive/v2.dart' as drive;
import 'base_storage_manager.dart';
import '../../errors.dart';

class GoogleDriveStorageManager extends BaseStorageManager {
  String storageIdentifier = "gdrive";

  final scopes = [drive.DriveApi.DriveScope];
  auth.AutoRefreshingAuthClient authClient;
  var api;
  GoogleDriveStorageManager() {

  }

  Future initializeStorage(Map config)async {
    var accountCredentials = new auth.ServiceAccountCredentials.fromJson(config);
    authClient = await auth.clientViaServiceAccount(accountCredentials, scopes);
    api = new drive.DriveApi(authClient);
  }

  Future<String> storeFile(File file,{String appName, String version, String filename, String contentType}) async {
    var media = new Media(file.openRead(), file.lengthSync());
    var driveFile = new drive.File();
    if (filename != null){
      driveFile.title = filename;
    }

    if(contentType != null){
      driveFile.mimeType = contentType;
    }
    var result = await api.files.insert(driveFile, uploadMedia: media);
    if (result == null){
      throw new ArtifactError("Error on saving file");
    }
    return generateStorageInfos(result.id);
  }

  Future<Stream> getStreamFromStoredFile(String storedInfos) async{
    String objectId= extractStorageId(storedInfos);
    drive.File file =  await api.files.get(objectId);
    var bytes = await authClient.readBytes(file.downloadUrl);
    //print(new AsciiDecoder().convert(bytes));
    var tmpDirectory = await Directory.systemTemp.createTemp('mdt');
    var tmpFile = new File('${tmpDirectory.path}/$objectId');
    await tmpFile.writeAsBytes(bytes,flush:true);
    return tmpFile.openRead();
/*
    .createSync(recursive:true);
    var stream = tmpFile.openWrite()..add(bytes);
    return stream;*/
  }

  Future deleteStoredFile(String storedInfos) async{
    String objectId= extractStorageId(storedInfos);
    return api.files.delete(objectId);
  }

  Future<Uri> storageUrI(String infos) async{
    throw new ArtifactError('Not supported by this storage');
  }
}