/// Warning! That file is generated. Do not edit it manually
part of domain_model;

class $MDTUser {
  static String get name => 'name';
  static String get email => 'email';
  static String get password => 'password';
  static String get externalTokenId => 'externalTokenId';
  static String get isSystemAdmin => 'isSystemAdmin';
  static final List<String> allFields = [name, email, password, externalTokenId, isSystemAdmin];
}

class MDTUser extends PersistentObject {
  String get name => getProperty('name');
  set name (String value) => setProperty('name',value);
  String get email => getProperty('email');
  set email (String value) => setProperty('email',value);
  String get password => getProperty('password');
  set password (String value) => setProperty('password',value);
  String get externalTokenId => getProperty('externalTokenId');
  set externalTokenId (String value) => setProperty('externalTokenId',value);
  bool get isSystemAdmin => getProperty('isSystemAdmin');
  set isSystemAdmin (bool value) => setProperty('isSystemAdmin',value);
}

class $MDTBaseObject {
  static String get objectType => 'objectType';
  static String get uuid => 'uuid';
  static final List<String> allFields = [objectType, uuid];
}

class MDTBaseObject extends PersistentObject {
  String get objectType => getProperty('objectType');
  set objectType (String value) => setProperty('objectType',value);
  String get uuid => getProperty('uuid');
  set uuid (String value) => setProperty('uuid',value);
}

class $MDTArtifact {
  static String get name => 'name';
  static String get creationDate => 'creationDate';
  static String get application => 'application';
  static String get version => 'version';
  static String get sortIdentifier => 'sortIdentifier';
  static String get storageInfos => 'storageInfos';
  static final List<String> allFields = [name, creationDate, application, version, sortIdentifier, storageInfos];
}

class MDTArtifact extends PersistentObject {
  String get name => getProperty('name');
  set name (String value) => setProperty('name',value);
  DateTime get creationDate => getProperty('creationDate');
  set creationDate (DateTime value) => setProperty('creationDate',value);
  MDTApplication get application => getLinkedObject('application');
  set application (MDTApplication value) => setLinkedObject('application',value);
  String get version => getProperty('version');
  set version (String value) => setProperty('version',value);
  String get sortIdentifier => getProperty('sortIdentifier');
  set sortIdentifier (String value) => setProperty('sortIdentifier',value);
  String get storageInfos => getProperty('storageInfos');
  set storageInfos (String value) => setProperty('storageInfos',value);
}

class $MDTApplication {
  static String get apiKey => 'apiKey';
  static String get name => 'name';
  static String get platform => 'platform';
  static String get adminUsers => 'adminUsers';
  static String get lastVersion => 'lastVersion';
  static final List<String> allFields = [apiKey, name, platform, adminUsers, lastVersion];
}

class MDTApplication extends PersistentObject {
  String get apiKey => getProperty('apiKey');
  set apiKey (String value) => setProperty('apiKey',value);
  String get name => getProperty('name');
  set name (String value) => setProperty('name',value);
  String get platform => getProperty('platform');
  set platform (String value) => setProperty('platform',value);
  List<MDTUser> get adminUsers => getPersistentList(MDTUser,'adminUsers');
  MDTArtifact get lastVersion => getLinkedObject('lastVersion');
  set lastVersion (MDTArtifact value) => setLinkedObject('lastVersion',value);
}

registerClasses() {
  objectory.registerClass(MDTUser,()=>new MDTUser(),()=>new List<MDTUser>());
  objectory.registerClass(MDTBaseObject,()=>new MDTBaseObject(),()=>new List<MDTBaseObject>());
  objectory.registerClass(MDTArtifact,()=>new MDTArtifact(),()=>new List<MDTArtifact>());
  objectory.registerClass(MDTApplication,()=>new MDTApplication(),()=>new List<MDTApplication>());
}
