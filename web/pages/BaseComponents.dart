import 'package:angular/angular.dart';
import 'package:angular_ui/angular_ui.dart';

class BaseComponent  implements ScopeAware {
  MainComponent mainComp(){
    return scope.parentScope.context;
  }
  Scope scope;
  bool isHttpLoading = false;
}

//Model
class MDTUser {
  String name;
  String email;
  String password;
  String externalTokenId;
  bool isSystemAdmin;
}

class MDTApplication {
  String uuid;
  String apiKey;
  String name;
  String platform;
  String description;
  List<MDTUser> adminUsers;
  List<MDTArtifact> lastVersion;
}

class MDTArtifact{
  String uuid;
  String branch;
  String name;
  DateTime creationDate;
  MDTApplication application;
  String version;
  String sortIdentifier;
  String storageInfos;
  String metaDataTags;
}