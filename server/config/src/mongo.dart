// Copyright (c) 2016, the Mobile App Distribution Tool project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'package:mongo_dart/mongo_dart.dart';
import 'dart:async';
import 'package:objectory/objectory_console.dart';
import '../../model/model.dart';
import '../config.dart' as config;
import '../../utils/utils.dart';

Db mongoDb = null;

//Objectory globalObjectory = nil;

 Future initialize({bool dropCollectionOnStartup:false}) async {

  if (objectory != null) {
   return objectory.ensureInitialized();
  }
  //mongoDb =  new Db("mongodb://localhost:27017/mdt_dev");
  var isDatabaseReady = false;
  while(!isDatabaseReady) {
   try {
  //const Uri = "mongodb://localhost:27017/mdt_dev";
  var Uri = config.currentLoadedConfig[config.MDT_DATABASE_URI];
  printAndLog("mongo located on  $Uri");
  objectory = new ObjectoryDirectConnectionImpl(Uri, registerClasses, false);
  if (dropCollectionOnStartup == true) {
   objectory.dropCollectionsOnStartup = true;
  }
    printAndLog("mongo initializing... ");
    //globalObjectory = objectory;
    await objectory.initDomainModel();
    isDatabaseReady = true;
    printAndLog("mongo initialized");
   } catch  (e){
    printAndLog("mongo initializing failed [$e], waiting 3 secs before next try ..");
    await new Future.delayed(new Duration(seconds: 3));
   }
  }
 // return await mongoDb.open();
}

Future dropCollections() async {
 return objectory.dropCollections();
}

void close() {
 objectory.close();
 objectory=null;
}