// Copyright (c) 2016, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import "all_core_tests.dart" as core;
import "all_rpc_tests.dart" as rpc;
import '../server/config/src/mongo.dart' as mongo;
import '../server/config/config.dart' as config;
import '../server/config/src/storage.dart' as storage;
import 'package:objectory/objectory_console.dart';
import 'package:test/test.dart';

void main() {
  test("init ", () async {
    await config.loadConfig();
    await mongo.initialize(dropCollectionOnStartup:true);
    await storage.initialize();
  });
  test ("Clean database", ()async {
    await objectory.dropCollections();
  });
  core.allTests();
  test ("Clean database", ()async {
    await objectory.dropCollections();
  });
  rpc.allTests();

  test("close database", () {
    mongo.close();
  });
}