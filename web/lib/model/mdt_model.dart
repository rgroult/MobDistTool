import 'dart:convert';

//Model
class MDTUser {
  String name;
  String email;
  bool isActivated;
  bool passwordStrengthFailed;
  // String externalTokenId;
  bool isSystemAdmin;
  List<String> favoritesApplicationsUUID;
  MDTUser(Map map){
    name = map["name"];
    email = map["email"];
    isActivated = map["isActivated"];
    // externalTokenId = map["externalTokenId"];
    isSystemAdmin = map["isSystemAdmin"];
    passwordStrengthFailed = map["passwordStrengthFailed"];
    if (map["favoritesApplicationsUUID"] != null){
      try{
        favoritesApplicationsUUID = JSON.decode(map["favoritesApplicationsUUID"] );
      }catch(e){
        favoritesApplicationsUUID = new List<String>();
      }
    }else {
      favoritesApplicationsUUID = new List<String>();
    }
  }
}

class UserListResponse {
  bool hasMore = false;
  int pageIndex;
  List<MDTUser> users = new List<MDTUser>();
}

class MDTApplication {
  String uuid;
  String apiKey;
  String name;
  String platform;
  String description;
  String appIcon;
  String maxVersionSecretKey;
  List<MDTUser> adminUsers;
  List<MDTArtifact> lastVersion;
  MDTApplication(Map map){
    uuid = map["uuid"];
    apiKey = map["apiKey"];
    name = map["name"];
    platform = map["platform"];
    description = map["description"];
    appIcon = map["appIcon"];
    maxVersionSecretKey = map["maxVersionSecretKey"];
   // appIcon = "http://www.winmacsofts.com/wp-content/uploads/2014/10/Clash-of-Clans-pour-PC-et-Mac-550x412.jpg";
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