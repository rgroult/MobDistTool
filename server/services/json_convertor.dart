import 'dart:mirrors';
import '../model/model.dart';
import 'dart:convert';
import 'package:bson/bson.dart';
import '../../packages/objectory/objectory.dart';

Map propertiePerClass = {
  "MDTUser" :  ['name','email'],
  "admin_MDTUser" :  ['isSystemAdmin'],
  'MDTApplication' :  ['name','platform','lastVersion','adminUsers','uuid','description'],
  'admin_MDTApplication' :  ['apiKey'],
  //'MDTArtifact' : ['uuid','branch','name','creationDate','version','sortIdentifier','metaDataTags'],
  'MDTArtifact' : ['uuid','branch','name','version','sortIdentifier','metaDataTags','size'],
  'admin_MDTArtifact' :  []
};

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
      listProperties.addAll(propertiePerClass['admin_${object.runtimeType.toString()}']);
    }
    for (var property in listProperties) {
      var value = object.getProperty(property);
      if (value is List) {
        //list of object
        json[property] = listToJson(value);
        /*
        if (value.length > 0) {
          var first = value.first;
          var test = new Symbol(value.first.collection);
          json[property] = listToJson(object.getPersistentList(reflect(value.first.collection), property), isAdmin:isAdmin);
        }*/
      } else if (value is PersistentObject) {
        //mongodb object
        json[property] = toJson(value, isAdmin:isAdmin);
      } else  if (value != null) {
        //value
        json[property] = value;
      }
    }
  }
  return json;
}

List listToJson(List<PersistentObject> objects, {bool isAdmin:false}){
  /*if (value is DbRef) {
      return objectory.dbRef2Object(value);
    }*/
  var result = [];
  if (objects != null) {
    for (var object in objects) {
      var elt = object;
      if (object is DbRef) {
        elt = objectory.dbRef2Object(object);
      }
      result.add(toJson(elt, isAdmin:isAdmin));
    }
  }
  return result;
}

String parseTags(String tags){
  try {
    if (tags == null) {
      return null;
    }
    var object = JSON.decode(tags);
    if (object != null) {
      return JSON.encode(object);
    }
  }
  catch(e){
    print("$e");
  }
  return null;
}

//PersistentObject objectById