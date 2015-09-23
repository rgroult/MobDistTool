library MDT_model_proto;
import 'package:objectory/src/domain_model_generator.dart';
import 'dart:mirrors';

//typedef UUID  = String;
//type UUID = String;

class MDTBaseObject {
  String objectType;
  String uuid;
}

class MDTUser extends MDTBaseObject {
  String name;
  String email;
  String password;
  String externalTokenId;
  bool isSystemAdmin;
}

//enum platformType { IOS, ANDROID }
class MDTApplication extends MDTBaseObject {
  String name;
  String platform;
  List<MDTUser> adminUsers;
  MDTArtifact lastVersion;
}

class MDTArtifact extends MDTBaseObject {
  String name;
  DateTime creationDate;
  MDTApplication application;
  String version;
  String sortIdentifier;
  String storageInfos;
}

main() {
  new ModelGenerator(#MDT_model_proto).generateTo('model_generated.dart');
}