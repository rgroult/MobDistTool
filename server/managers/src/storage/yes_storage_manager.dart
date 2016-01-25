import 'dart:async';
import 'dart:io';
import '../artifacts_manager.dart';
import 'base_storage_manager.dart';
import '../../errors.dart';

class YesStorageManager extends BaseStorageManager {
  String storageIdentifier = "YesStorage";

  Future<String> storeFile(File file, {String filename, String contentType}) async {
    return new Future.value(generateStorageInfos("fakeFile"));
  }

  Future<Stream> getStreamFromStoredFile(String storedInfos) async{
    var file = new File(Directory.current.path+"/server/managers/src/storage" +"/yes_storage_sample.txt");
    return file.openRead();
  }

  Future<bool> deleteStoredFile(String storedInfos) async{
    return new Future.value(true);
  }

  Future<Uri> storageUrI(String infos)async {
    return new Future.value(generateStorageInfos("fakeFile"));
  }

/*
  //static var sharedInstance => new StorageManager()

  bool checkInfos(String infos){
    var result = infos.matchAsPrefix("YesStorage");
    return ("YesStorage".matchAsPrefix(infos) !=null);
  }

  bool canHandleStorageUrl(){
    return true;
  }

  Future<Uri> storageUrI(String infos) {
    var uri = Uri.parse("https://github.com/rgroult/MobDistTool/blob/master/test/artifactFile.txt");
    return new Future.value(uri);
  }

  Future<File> storageFile(String infos) async {
    if (checkInfos(infos)){
      return new File(Directory.current.path+"/server/managers/src/storage" +"/yes_storage_sample.txt");
    }
    throw new ArtifactError('Bad infos');
  }

  Future<String> storeFile(File file) {
    return new Future.value("YesStorageManager");
  }

  Future<bool> deleteFile(File file) {
    return new Future.value(true);
  }

  Future<bool> deleteFileFromInfos(String infos) {
    if (checkInfos(infos)){
      return new Future.value(true);
    }
    throw new ArtifactError('Bad infos');
  }*/
}