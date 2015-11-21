import '../../../packages/mongo_dart/mongo_dart.dart';
import 'dart:async';
import '../../../packages/objectory/objectory_console.dart';
import '../../model/model.dart';

Db mongoDb = null;

//Objectory globalObjectory = nil;

 Future initialize({bool dropCollectionOnStartup:false}) async {
  if (objectory != null) {
   await objectory.ensureInitialized();
    return new Future.value(null);
  }
  //mongoDb =  new Db("mongodb://localhost:27017/mdt_dev");
  const Uri = "mongodb://localhost:27017/mdt_dev";
  objectory = new ObjectoryDirectConnectionImpl(Uri,registerClasses,true);
  if (dropCollectionOnStartup == true) {
  objectory.dropCollectionsOnStartup = true;
  }
  //globalObjectory = objectory;
  return objectory.initDomainModel();
 // return await mongoDb.open();
}
