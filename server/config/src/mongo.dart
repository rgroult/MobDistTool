import '../../../packages/mongo_dart/mongo_dart.dart';
import 'dart:async';
import '../../../packages/objectory/objectory_console.dart';
import '../../model/model.dart';
import '../config.dart' as config;

Db mongoDb = null;

//Objectory globalObjectory = nil;

 Future initialize({bool dropCollectionOnStartup:false}) async {

  if (objectory != null) {
   return objectory.ensureInitialized();
    return new Future.value(null);
  }
  //mongoDb =  new Db("mongodb://localhost:27017/mdt_dev");

  //const Uri = "mongodb://localhost:27017/mdt_dev";
  var Uri = config.currentLoadedConfig["mongoURL"];
  print("mongo initializing on  $Uri");
  objectory = new ObjectoryDirectConnectionImpl(Uri,registerClasses,false);
  if (dropCollectionOnStartup == true) {
    objectory.dropCollectionsOnStartup = true;
  }
  //globalObjectory = objectory;
  return objectory.initDomainModel();
 // return await mongoDb.open();
}

void close() {
 objectory.close();
 objectory=null;
}