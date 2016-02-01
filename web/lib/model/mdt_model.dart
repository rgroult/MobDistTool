import 'package:angular/angular.dart';
import 'dart:convert';

//Model
class MDTUser {
  String name;
  String email;
  // String externalTokenId;
  bool isSystemAdmin;
  MDTUser(Map map){
    name = map["name"];
    email = map["email"];
    // externalTokenId = map["externalTokenId"];
    isSystemAdmin = map["isSystemAdmin"];
  }
}


class MDTApplication {
  String uuid;
  String apiKey;
  String name;
  String platform;
  String description;
  String appIcon;
  List<MDTUser> adminUsers;
  List<MDTArtifact> lastVersion;
  MDTApplication(Map map){
    uuid = map["uuid"];
    apiKey = map["apiKey"];
    name = map["name"];
    platform = map["platform"];
    description = map["description"];
    appIcon = "http://www.winmacsofts.com/wp-content/uploads/2014/10/Clash-of-Clans-pour-PC-et-Mac-550x412.jpg";
    //admin user
    adminUsers = new List<MDTUser>();
    var aUsers =  map["adminUsers"];
    if (aUsers != null) {
      for (Map map in aUsers) {
        adminUsers.add(new MDTUser(map));
      }
    }
    //last version
    lastVersion = new List<MDTArtifact>();
    var last = map["lastVersion"];
    if (last != null) {
      for (Map map in last) {
        lastVersion.add(new MDTArtifact(map));
      }
    }
  }
}

class MDTArtifact{
  String uuid;
  String branch;
  String name;
  int size;
  DateTime creationDate;
  MDTApplication application;
  String version;
  String sortIdentifier;
  // String storageInfos;
  Map metaDataTags;
  MDTArtifact(Map map){
    uuid = map["uuid"];
    branch = map["branch"];
    name = map["name"];
    creationDate = map["creationDate"];
    version = map["version"];
    sortIdentifier = map["sortIdentifier"];
    size = map['size']!=null ? map['size']:0;
    if (map["metaDataTags"] != null) {
      metaDataTags = JSON.decode(map["metaDataTags"]);
    }
  }
}