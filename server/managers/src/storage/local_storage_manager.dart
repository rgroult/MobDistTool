// Copyright (c) 2016, Rémi Groult.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'base_storage_manager.dart';
import '../../errors.dart';

class LocalStorageManager extends BaseStorageManager {
  String storageIdentifier = "LocalStorage";
  String rootStoragePath = "";
  Future initializeStorage(Map config)async {
    rootStoragePath = config["RootDirectory"];
    if (rootStoragePath == null){
      throw new ArgumentError("Unable to initialize Local Storage: RootDirectory configuration not found");
    }
  }

  Future<String> storeFile(File file,
      {String platform,String appName, String version, String filename, String contentType}) async {
    try{
      //need all optianals arguments
      if (platform == null || appName == null || version == null|| filename == null|| contentType == null){
        throw new ArtifactError("Error on saving file, missing mandatory parameters values.");
      }
      var rnd = new Random();
      var alea = rnd.nextInt(1234567);
      var storeRelativeFilename = "/${platform.replaceAll(new RegExp(r' '), '_')}_${appName.replaceAll(new RegExp(r' '), '_')}/${version.replaceAll(new RegExp(r' '), '_')}/${filename.replaceAll(new RegExp(r' '), '_')}${alea}";
      var storeAbsoluteFilename = "${rootStoragePath}/$storeRelativeFilename";

      var storeFile = new File("$storeAbsoluteFilename");
      await storeFile.create(recursive:true);

      var fileToStoresink = file.openRead();
      var fileStoredSink = storeFile.openWrite();

      await fileToStoresink.pipe(fileStoredSink);
      //await storeFile.closeSync();
      //await file.closeSync();

      return new Future.value(generateStorageInfos(storeRelativeFilename));
    }catch(e){
      print("Local File Manager :Write Error : ${e.toString()}");
      throw new ArtifactError("Error on saving file");
    }
  }

  Future<Stream> getStreamFromStoredFile(String storedInfos) async {
    try{
        String filename = extractStorageId(storedInfos);
        var file = new File("${rootStoragePath}/$filename");
    return file.openRead();
    }catch(e){
      print("Local File Manager :Read Error : ${e.toString()}");
      throw new ArtifactError("Error on reading file");
    }
  }

  Future<bool> deleteStoredFile(String storedInfos) async {
    try{
    String filename = extractStorageId(storedInfos);
    var file = new File("${rootStoragePath}/$filename");
    await file.delete();
    return new Future.value(true);
    }catch(e){
      print("Local File Manager :Delete Error : ${e.toString()}");
      throw new ArtifactError("Error on deleting file");
    }
  }

  Future<Uri> storageUrI(String infos) async {
    throw new ArtifactError('Not supported by this storage');
  }
}