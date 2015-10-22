import 'dart:async';
import 'dart:io';
import '../../../packages/objectory/objectory_console.dart';
import '../../model/model.dart';
import 'storage/yes_storage_manager.dart';
import '../errors.dart';

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

BaseStorageManager defaultStorage = new YesStorageManager();

var artifactCollection = objectory[MDTArtifact];

Future<List<MDTArtifact>> allArtifacts() {
  return artifactCollection.find();
}

Future<List<MDTArtifact>> findAllArtifacts(MDTApplication app) async {
  return artifactCollection.find(where.eq('application',app.id));
}

Future<MDTArtifact> findArtifact(String uuid)async{
  return artifactCollection.find(where.eq('uuid',uuid));
}

Future<MDTArtifact> createArtifact(MDTApplication app,String name,String version, {String sortIdentifier, Map tags}) async {
  var artifact = new MDTArtifact()
    ..application = app
    ..name = name
    ..version = version;

  if (sortIdentifier != null){
    artifact.sortIdentifier = sortIdentifier;
  }else {
    artifact.sortIdentifier = version;
  }
  if (tags != null) {
    // TO DO
  }
  await artifact.save();
  return artifact;
}

//if previous file found, delete it before
Future addFileToArtifact(File file,MDTArtifact artifact,BaseStorageManager storageMgr) async {
  //delete previous file
  await deleteArtifactFile(artifact,storageMgr);

  //store new file
  try {
    var storageInfos = await storageMgr.storeFile(file);
    artifact.storageInfos = storageInfos;
    return artifact.save();
  }on Error catch(e){
    throw new ArtifactError('Unable to store file:'+e.toString());
  }
}

Future<File> fileFromArtifact(MDTArtifact artifact,BaseStorageManager storageMgr) async {
  if (artifact == null || artifact.storageInfos == null) {
    throw new ArtifactError('Unable to find file artifact:'+artifact.name);
  }
  return storageMgr.storageFile(artifact.storageInfos);
}

Future<Uri> uriFromArtifact(MDTArtifact artifact,BaseStorageManager storageMgr) async {
  if (artifact == null || artifact.storageInfos == null) {
    throw new ArtifactError('Unable to find file artifact');
  }

  if (!storageMgr.canHandleStorageUrl()){
    throw new ArtifactError('Unable to handle storage Uri');
  }
  return storageMgr.storageUrI(artifact.storageInfos);
}

Future deleteArtifactFile(MDTArtifact artifact,BaseStorageManager storageMgr) async {
  if (artifact.storageInfos == null) {
    return new Future.value(true);
  }
  try {
    await storageMgr.deleteFileFromInfos(artifact.storageInfos);
    artifact.storageInfos = null;
    return artifact.save();
  } on ArtifactError catch (e) {
    throw new ArtifactError('Unable to delete file artifact:'+e.message);
  }
}

Future deleteArtifact(MDTArtifact artifact,BaseStorageManager storageMgr) async {
  try {
    await deleteArtifactFile(artifact, storageMgr);
    return artifact.remove();
  }on Error catch(e){
    throw new ArtifactError('Unable to delete artifact:'+e.toString());
  }
}


Future deleteAllArtifacts(MDTApplication app,BaseStorageManager storageMgr) async {
  List<MDTArtifact> artifacts = await findAllArtifacts(app);
  //delete all artifact
  var toWait = [];
  try {
    for (var artifact in artifacts){
     toWait.add(deleteArtifact(artifact,storageMgr));
    }
    return Future.wait(toWait);
  }on Error catch(e){
    throw new ArtifactError('Unable to delete artifacts:'+e.toString());
  }
}


class BaseStorageManager {

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
}