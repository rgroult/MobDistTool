import '../model/model.dart';

Map propertiePerClass = {
  MTDUser.runtimeType.toString() :  ['name,email'],
  MTDAppliction.toString() :  ['name','email','lastVersion'],
  'admin_${MTDAppliction.toString()}' :  ['apiKey'],
  MDTArtifact.toString() : ['branch','branch','creationDate','version','sortIdentifier']
};

/*
Map toJson(MTDUser user) {
  return {};
}

Map toJson(MDTApplication app) {
  return {};
}

Map toJson(MDTArtifact artifact) {
  return {};
}

Map toJson<T>(List<T> listElt) {
return {};
}
*/

Map toJson(PersistentObject object, {Bool isAdmin:false}){
  var json = {};
  if (object != null) {
    var listProperties = new List<String>();
    listProperties.addAll(object.runtimeType.toString());
    if (isAdmin) {
      listProperties.addAll('admin_${object.toString()}');
    }
    for (property in listProperties) {
      var value = object.getProperty(property);
      if (value is List) {
        //list of object
        json[property] = listToJson(value, isAdmin:isAdmin);
      } else if (value is PersistentObject) {
        //mongodb object
        json[property] = toJson(value, isAdmin:isAdmin);
      } else {
        //value
        json[property] = value;
      }
    }
  }
  return json;
}

List listToJson(List<PersistentObject> objects, {Bool isAdmin:false}){
  var result = [];
  if (objects != null) {
    for (object in objects) {
      result.add(toJson(object, isAdmin:isAdmin));
    }
  }
  return result;
}