import 'dart:async';
import 'package:objectory/objectory_console.dart';
import '../model/model.dart';
import 'errors.dart';

/*
class MDTArtifact extends MDTBaseObject {
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
