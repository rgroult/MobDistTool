import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper_mongo/metadata.dart';

class MDTUser {
  static final String collectionName = "MDTUser";
  @Id()
  String id;
  @Field()
  String name;
  @Field()
  String email;
  @Field()
  String password;
  @Field()
  String salt;
  // String externalTokenId;
  @Field()
  String activationToken;
  @Field()
  bool isSystemAdmin;
  @Field()
  bool isActivated;
  @Field()
  String favoritesApplicationsUUID; //List<String> not handle by Model generator : generate PersistentList
}

//enum platformType { IOS, ANDROID }
class MDTApplication {
  static final String collectionName = "MDTApplication";
  @Id()
  String id;
  @Field()
  String uuid;
  @Field()
  String apiKey;
  @Field()
  String maxVersionSecretKey;
  @Field()
  String base64IconData;
  @Field()
  String name;
  @Field()
  String platform;
  @Field()
  String description;
  @ReferenceId()
  List<MDTUser> adminUsers;
}

class MDTArtifact {
  static final String collectionName = "MDTArtifact";
  @Field()
  String uuid;
  @Field()
  String branch;
  @Field()
  String name;
  @Field()
  String contentType;
  @Field()
  String filename;
  @Field()
  DateTime creationDate;
  @Field()
  int size;
  @Field()
  ReferenceId application;
  @Field()
  String version;
  @Field()
  String sortIdentifier;
  @Field()
  String storageInfos;
  @Field()
  String metaDataTags;
}