import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../../packages/objectory/objectory_console.dart';
import '../../model/model.dart';
import 'storage/yes_storage_manager.dart';
import 'storage/base_storage_manager.dart';
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

BaseStorageManager defaultStorage;// = new YesStorageManager();
var UuidGenerator = new Uuid();

var artifactCollection = objectory[MDTArtifact];

Future<List<MDTArtifact>> allArtifacts() {
  return artifactCollection.find();
}

Future<List<MDTArtifact>> findAllArtifacts(MDTApplication app) async {
  return artifactCollection.find(where.eq('application',app.id));
}

Future<MDTArtifact> findArtifact(String uuid)async{
  return artifactCollection.findOne(where.eq('uuid',uuid));
}

Future<MDTArtifact> findArtifactByInfos(MDTApplication app,String branch,String version, String artifactName)async{
  var query = where.eq('application',app.id).eq('branch', branch).eq('version', version).eq('name', artifactName);
  return artifactCollection.findOne(query);
}

Future<MDTArtifact> createArtifact(MDTApplication app,String name,String version, String branch,{String sortIdentifier, String tags}) async {
  var artifact = new MDTArtifact()
    ..application = app
    ..name = name
    ..version = version
    ..branch = branch
    ..creationDate = new DateTime.now()
    ..uuid = UuidGenerator.v4();

  if (sortIdentifier != null){
    artifact.sortIdentifier = sortIdentifier;
  }else {
    artifact.sortIdentifier = version;
  }
  if (tags != null) {
    artifact.metaDataTags = tags;
  }
  await artifact.save();
  return artifact;
}
/*
Future<MDTArtifact> createLastVersionArtifact(MDTApplication app,String name,{ Map tags}) async {
  //check in app lastversion contains name artifact
  if (app.lastVersion.contains(name)){

  }
  var artifact = new MDTArtifact()
    ..name = name
    ..creationDate = new DateTime.now()
    ..uuid = UuidGenerator.v4();

  if (tags != null) {
    // TO DO
  }
  await artifact.save();
  return artifact;
}
*/
/* String uuid;
String branch;
String name;
String contentType;
String filename;
DateTime creationDate;
int size;
MDTApplication application;
String version;
String sortIdentifier;
String storageInfos;
String metaDataTags;*/

//if previous file found, delete it before
Future addFileToArtifact(File file,MDTArtifact artifact,BaseStorageManager storageMgr) async {
  //delete previous file
  await deleteArtifactFile(artifact,storageMgr);

  //store new file
  try {
    var storageInfos = await storageMgr.storeFile(file,filename:artifact.filename, contentType:artifact.contentType);
    artifact.storageInfos = storageInfos;

    return artifact.save();
  }on Error catch(e){
    throw new ArtifactError('Unable to store file:'+e.toString());
  }
}

//first page : pageIndex = 1
Future<List<MDTArtifact>> searchArtifacts(MDTApplication app, {int pageIndex,int limitPerPage:25,String branch,String branchToExclude}) async{
  var page = pageIndex!=null?pageIndex:1;
  var numberPerPage = limitPerPage!=null?limitPerPage:25;
  page = max(1,page);
  var numberToSkip = (page-1)*numberPerPage;
  var query = where.eq('application',app.id).sortBy("creationDate",descending:true).skip(numberToSkip).limit(numberPerPage);
  if (branch!=null){
    query=query.eq('branch',branch);
  }
  if (branchToExclude != null) {
    query=query.ne('branch',branchToExclude);
  }
  return artifactCollection.find(query);
}

Future<Stream> streamFromArtifact(MDTArtifact artifact,BaseStorageManager storageMgr) async {
  if (artifact == null || artifact.storageInfos == null) {
    throw new ArtifactError('Unable to find file artifact:'+artifact.name);
  }
  return storageMgr.getStreamFromStoredFile(artifact.storageInfos);
}

Future<Uri> uriFromArtifact(MDTArtifact artifact,BaseStorageManager storageMgr) async {
  if (artifact == null || artifact.storageInfos == null) {
    throw new ArtifactError('Unable to find file artifact');
  }

  return storageMgr.storageUrI(artifact.storageInfos);

  /*if (!storageMgr.canHandleStorageUrl()){
    throw new ArtifactError('Unable to handle storage Uri');
  }
  return storageMgr.storageUrI(artifact.storageInfos);*/
}

Future deleteArtifactFile(MDTArtifact artifact,BaseStorageManager storageMgr) async {
  if (artifact.storageInfos == null) {
    return new Future.value(true);
  }
  try {
    var result = await storageMgr.deleteStoredFile(artifact.storageInfos);
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