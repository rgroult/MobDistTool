/// Warning! That file is generated. Do not edit it manually
part of domain_model;

class $MDTUser {
  static String get name => 'name';
  static String get email => 'email';
  static String get password => 'password';
  static String get externalTokenId => 'externalTokenId';
  static String get activationToken => 'activationToken';
  static String get isSystemAdmin => 'isSystemAdmin';
  static String get isActivated => 'isActivated';
  static final List<String> allFields = [name, email, password, externalTokenId, activationToken, isSystemAdmin, isActivated];
  static final List<PropertyDescriptor> simpleFields = [
    const PropertyDescriptor('name', PropertyType.String, 'name')
    ,const PropertyDescriptor('email', PropertyType.String, 'email')
    ,const PropertyDescriptor('password', PropertyType.String, 'password')
    ,const PropertyDescriptor('externalTokenId', PropertyType.String, 'externalTokenId')
    ,const PropertyDescriptor('activationToken', PropertyType.String, 'activationToken')
    ,const PropertyDescriptor('isSystemAdmin', PropertyType.bool, 'isSystemAdmin')
    ,const PropertyDescriptor('isActivated', PropertyType.bool, 'isActivated')
  ];
}

class MDTUser extends PersistentObject {
  String get collectionName => 'MDTUser';
  List<String> get $allFields => $MDTUser.allFields;
  String get name => getProperty('name');
  set name (String value) => setProperty('name',value);
  String get email => getProperty('email');
  set email (String value) => setProperty('email',value);
  String get password => getProperty('password');
  set password (String value) => setProperty('password',value);
  String get externalTokenId => getProperty('externalTokenId');
  set externalTokenId (String value) => setProperty('externalTokenId',value);
  String get activationToken => getProperty('activationToken');
  set activationToken (String value) => setProperty('activationToken',value);
  bool get isSystemAdmin => getProperty('isSystemAdmin');
  set isSystemAdmin (bool value) => setProperty('isSystemAdmin',value);
  bool get isActivated => getProperty('isActivated');
  set isActivated (bool value) => setProperty('isActivated',value);
}

class $MDTArtifact {
  static String get uuid => 'uuid';
  static String get branch => 'branch';
  static String get name => 'name';
  static String get contentType => 'contentType';
  static String get filename => 'filename';
  static String get creationDate => 'creationDate';
  static String get size => 'size';
  static String get application => 'application';
  static String get version => 'version';
  static String get sortIdentifier => 'sortIdentifier';
  static String get storageInfos => 'storageInfos';
  static String get metaDataTags => 'metaDataTags';
  static final List<String> allFields = [uuid, branch, name, contentType, filename, creationDate, size, application, version, sortIdentifier, storageInfos, metaDataTags];
  static final List<PropertyDescriptor> simpleFields = [
    const PropertyDescriptor('uuid', PropertyType.String, 'uuid')
    ,const PropertyDescriptor('branch', PropertyType.String, 'branch')
    ,const PropertyDescriptor('name', PropertyType.String, 'name')
    ,const PropertyDescriptor('contentType', PropertyType.String, 'contentType')
    ,const PropertyDescriptor('filename', PropertyType.String, 'filename')
    ,const PropertyDescriptor('creationDate', PropertyType.DateTime, 'creationDate')
    ,const PropertyDescriptor('size', PropertyType.int, 'size')
    ,const PropertyDescriptor('version', PropertyType.String, 'version')
    ,const PropertyDescriptor('sortIdentifier', PropertyType.String, 'sortIdentifier')
    ,const PropertyDescriptor('storageInfos', PropertyType.String, 'storageInfos')
    ,const PropertyDescriptor('metaDataTags', PropertyType.String, 'metaDataTags')
  ];
}

class MDTArtifact extends PersistentObject {
  String get collectionName => 'MDTArtifact';
  List<String> get $allFields => $MDTArtifact.allFields;
  String get uuid => getProperty('uuid');
  set uuid (String value) => setProperty('uuid',value);
  String get branch => getProperty('branch');
  set branch (String value) => setProperty('branch',value);
  String get name => getProperty('name');
  set name (String value) => setProperty('name',value);
  String get contentType => getProperty('contentType');
  set contentType (String value) => setProperty('contentType',value);
  String get filename => getProperty('filename');
  set filename (String value) => setProperty('filename',value);
  DateTime get creationDate => getProperty('creationDate');
  set creationDate (DateTime value) => setProperty('creationDate',value);
  int get size => getProperty('size');
  set size (int value) => setProperty('size',value);
  MDTApplication get application => getLinkedObject('application', MDTApplication);
  set application (MDTApplication value) => setLinkedObject('application',value);
  String get version => getProperty('version');
  set version (String value) => setProperty('version',value);
  String get sortIdentifier => getProperty('sortIdentifier');
  set sortIdentifier (String value) => setProperty('sortIdentifier',value);
  String get storageInfos => getProperty('storageInfos');
  set storageInfos (String value) => setProperty('storageInfos',value);
  String get metaDataTags => getProperty('metaDataTags');
  set metaDataTags (String value) => setProperty('metaDataTags',value);
}

class $MDTApplication {
  static String get uuid => 'uuid';
  static String get apiKey => 'apiKey';
  static String get base64IconData => 'base64IconData';
  static String get name => 'name';
  static String get platform => 'platform';
  static String get description => 'description';
  static String get adminUsers => 'adminUsers';
  static final List<String> allFields = [uuid, apiKey, base64IconData, name, platform, description, adminUsers];
  static final List<PropertyDescriptor> simpleFields = [
    const PropertyDescriptor('uuid', PropertyType.String, 'uuid')
    ,const PropertyDescriptor('apiKey', PropertyType.String, 'apiKey')
    ,const PropertyDescriptor('base64IconData', PropertyType.String, 'base64IconData')
    ,const PropertyDescriptor('name', PropertyType.String, 'name')
    ,const PropertyDescriptor('platform', PropertyType.String, 'platform')
    ,const PropertyDescriptor('description', PropertyType.String, 'description')
  ];
}

class MDTApplication extends PersistentObject {
  String get collectionName => 'MDTApplication';
  List<String> get $allFields => $MDTApplication.allFields;
  String get uuid => getProperty('uuid');
  set uuid (String value) => setProperty('uuid',value);
  String get apiKey => getProperty('apiKey');
  set apiKey (String value) => setProperty('apiKey',value);
  String get base64IconData => getProperty('base64IconData');
  set base64IconData (String value) => setProperty('base64IconData',value);
  String get name => getProperty('name');
  set name (String value) => setProperty('name',value);
  String get platform => getProperty('platform');
  set platform (String value) => setProperty('platform',value);
  String get description => getProperty('description');
  set description (String value) => setProperty('description',value);
  List<MDTUser> get adminUsers => getPersistentList(MDTUser,'adminUsers');
}

registerClasses() {
  objectory.registerClass(MDTUser,()=>new MDTUser(),()=>new List<MDTUser>(), {});
  objectory.registerClass(MDTArtifact,()=>new MDTArtifact(),()=>new List<MDTArtifact>(), {'application': MDTApplication});
  objectory.registerClass(MDTApplication,()=>new MDTApplication(),()=>new List<MDTApplication>(), {});
}
