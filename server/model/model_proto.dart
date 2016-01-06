library MDT_model_proto;
import '../../packages/objectory/src/domain_model_generator.dart';

//typedef UUID  = String;
//type UUID = String;
/*
class MDTBaseObject {
  String objectType;
  String uuid;
}
*/
class MDTUser/* extends MDTBaseObject*/ {
  String name;
  String email;
  String password;
  String externalTokenId;
  bool isSystemAdmin;
}

//enum platformType { IOS, ANDROID }
class MDTApplication /*extends MDTBaseObject */{
  String uuid;
  String apiKey;
  String name;
  String platform;
  String description;
  List<MDTUser> adminUsers;
  List<MDTArtifact> lastVersion;
}

class MDTArtifact/* extends MDTBaseObject*/ {
  String uuid;
  String branch;
  String name;
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