import '../model/model.dart';
import '../../packages/objectory/objectory.dart';

Map propertiePerClass = {
  "MDTUser" :  ['name','email'],
  "admin_MDTUser" :  ['isSystemAdmin'],
  'MDTAppliction' :  ['name','platform','lastVersion','adminUsers'],
  'admin_MDTAppliction' :  ['apiKey'],
  'MDTArtifact' : ['branch','branch','creationDate','version','sortIdentifier'],
  'admin_MDTArtifact' :  [],
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

Map toJsonStringValues(PersistentObject object, List<String> properties){
  var json = {};
  for (var property in listProperties) {
    var value = object.getProperty(property);
    if (value is List) {
      //nothing
    } else if (value is PersistentObject) {
      //mongodb object
      //nothing
    } else {
      //value
      json[property] = value;
    }
  }
  return json;
}

Map toJson(PersistentObject object, {bool isAdmin:false}){
  var json = {};
  if (object != null) {
    var listProperties =  [];
    var classProperties = propertiePerClass[object.runtimeType.toString()];
    listProperties.addAll(classProperties);
    if (isAdmin) {
      listProperties.addAll(propertiePerClass['admin_${object.toString()}']);
    }
    for (var property in listProperties) {
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