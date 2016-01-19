import 'dart:io';
import '../managers/src/artifacts_manager.dart';
import "dart:mirrors";

//mongo DB URL

//artifact storage default name

// yes_storage , file_storage

//artifact storage configuration

//file_storage config
// rootPath

Map<String, Object> currentLoadedConfig = new Map<String, Object>();

dynamic instanceFromString(String objectName){
 /* MirrorSystem mirrors = currentMirrorSystem();
  LibraryMirror lm = mirrors.libraries.values.firstWhere(
          (LibraryMirror lm) => lm.qualifiedName == new Symbol('test'));

  ClassMirror cm = lm.declarations[new Symbol(objectName)];

  InstanceMirror im = cm.newInstance(new Symbol(''), []);
  var tc = im.reflectee;
  */
  return null;
}

void loadConfig(){
  Map<String, String> env = Platform.environment;
  //mongo db
  var mongoURL = env["MDT_DATABASE_URI"];
  if (mongoURL == null){
    mongoURL = "mongodb://localhost:27017/mdt_dev";
  }
  currentLoadedConfig["mongoURL"] = mongoURL;
}
