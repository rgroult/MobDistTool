// Copyright (c) 2016, the Mobile App Distribution Tool project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'package:mongo_dart/mongo_dart.dart';
import 'dart:async';
import 'package:redstone_mapper_mongo/manager.dart';

//import '../../../packages/objectory/objectory_console.dart';
//import '../../model/model.dart';
import '../config.dart' as config;
import '../../utils/utils.dart';

export 'package:redstone_mapper_mongo/manager.dart' show MongoDb;
export 'package:mongo_dart_query/mongo_dart_query.dart';
//Db mongoDb = null;

//Objectory globalObjectory = nil;

MongoDbManager _mongoDbManager = null;
final int poolSize = 3;

 Future initialize({bool dropCollectionOnStartup:false}) async {
  var Uri = config.currentLoadedConfig[config.MDT_DATABASE_URI];
  printAndLog("mongo initializing on  $Uri");
  _mongoDbManager = new MongoDbManager(Uri, poolSize: poolSize);
  if (dropCollectionOnStartup == true) {
    dropCollections();
  }
/*
  if (objectory != null) {
   return objectory.ensureInitialized();
  }
  //mongoDb =  new Db("mongodb://localhost:27017/mdt_dev");

  //const Uri = "mongodb://localhost:27017/mdt_dev";
  var Uri = config.currentLoadedConfig[config.MDT_DATABASE_URI];
  printAndLog("mongo initializing on  $Uri");
  objectory = new ObjectoryDirectConnectionImpl(Uri,registerClasses,false);
  if (dropCollectionOnStartup == true) {
    objectory.dropCollectionsOnStartup = true;
  }
  //globalObjectory = objectory;
  return objectory.initDomainModel();
 // return await mongoDb.open();*/
}
/*
Future dropCollections() async {
 return objectory.dropCollections();
}
*/
Future close() async {
  for (int i=0; i < poolSize; i++){
    var conn = await _mongoDbManager.getConnection();
    Db dbconn = conn.innerConn;
    await _mongoDbManager.closeConnection(conn);
    await dbconn.close();
    //printAndLog("mongo connection release:  $dbconn");
  }

/* objectory.close();
 objectory=null;*/
}

Future dropCollections() async {
  var conn = await getConnection();
  return conn.innerConn.drop();
}

Future<MongoDb> getConnection() async{
  return _mongoDbManager.getConnection();
}
