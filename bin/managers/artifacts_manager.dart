import 'dart:async';
import 'package:objectory/objectory_console.dart';
import '../model/model.dart';
import 'errors.dart';

/*
class MDTArtifact extends MDTBaseObject {
  String branch;
  String name;
  DateTime creationDate;
  MDTApplication application;
  String version;
  String sortIdentifier;
  String storageInfos;
}
 */

class ArtifactError extends StateError {
  ArtifactError(String msg) : super(msg);
}

var artifactCollection = objectory[MDTArtifact];

Future<List<MDTArtifact>> allArtifacts() {
  return artifactCollection.find();
}

Future<MDTArtifact> createArtifact(MDTApplication app,String name,String version, {String sortIdentifier, Map tags}) {
  var artifact = new MDTArtifact()
    ..application = app
    ..name = name
    ..version = version;

  if (sortIdentifier != null){
    artifact.sortIdentifier = sortIdentifier;
  }else {
    artifact.sortIdentifier = version;
  }
}
//add artifact to app
//delete artifact from app
//delete artifact



class BaseStorageManager {
  static var sharedInstance => new StorageManager()

  Future<File> storageFile(String infos) {
    throw new ArtifactError('Not implemented');
  }

  Future<String> storeFile(File file) {
    throw new ArtifactError('Not implemented');
  }

  Future<bool> deleteFile(File file) {
    throw new ArtifactError('Not implemented');
  }

  Future<bool> deleteFile(String infos) {
    throw new ArtifactError('Not implemented');
  }
}