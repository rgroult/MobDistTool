// Copyright (c) 2016, the Mobile App Distribution Tool project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

library MDT_model_proto;
import '../../packages/objectory/src/domain_model_generator.dart';

class MDTUser {
  String name;
  String email;
  String password;
  String salt;
 // String externalTokenId;
  String activationToken;
  bool isSystemAdmin;
  bool isActivated;
  String favoritesApplicationsUUID; //List<String> not handle by Model generator : generate PersistentList
}

//enum platformType { IOS, ANDROID }
class MDTApplication {
  String uuid;
  String apiKey;
  String maxVersionSecretKey;
  String base64IconData;
  String name;
  String platform;
  String description;
  List<MDTUser> adminUsers;
  //List<MDTArtifact> lastVersion;
}

class MDTArtifact {
  String uuid;
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
  String metaDataTags;
}

main() {
  new ModelGenerator(#MDT_model_proto).generateTo('bin/model/model_generated.dart');
}