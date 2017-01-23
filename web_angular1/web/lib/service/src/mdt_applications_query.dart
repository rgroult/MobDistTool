import 'package:angular/angular.dart';
import 'dart:convert';
import 'dart:async';
import '../../model/errors.dart';
import '../../model/mdt_model.dart';
import 'mdt_conf_query.dart';

abstract class MDTQueryServiceApplications {
  Future<HttpResponse> sendRequest(String method, String url,
      {String query, String body, String contentType}) async {
    throw 'Not Implemented';
  }
  Map parseResponse(HttpResponse response,{checkAuthorization:true}) {
    throw 'Not Implemented';
  }
  Future<MDTApplication> createApplication(
      String name, String description, String platform, String icon,bool maxVersionCheck) async {
    var appData = {
      "name": name,
      "description": description,
      "platform": platform,
      "base64IconData":icon,
      "enableMaxVersionCheck":maxVersionCheck
    };

    var response = await sendRequest(
        'POST', '${mdtServerApiRootUrl}${appPath}/create',
        body: JSON.encode(appData));
    var responseJson = parseResponse(response);

    if (responseJson["error"] != null) {
      throw new ApplicationError(responseJson["error"]["message"]);
    }

    var app = new MDTApplication(responseJson["data"]);
    app.appIcon= applicationIcon(app.uuid);
    return app;
  }

  Future<MDTApplication> updateApplication(
      String appId, String name, String description, String icon,bool maxVersionCheck) async {
    var appData = {"name": name, "description": description,"enableMaxVersionCheck":maxVersionCheck};
    if (icon !=null && icon.length>0){
      appData["base64IconData"] = icon;
    }

    var response = await sendRequest(
        'PUT', '${mdtServerApiRootUrl}${appPath}/app/$appId',
        body: JSON.encode(appData));
    var responseJson = parseResponse(response);

    if (responseJson["error"] != null) {
      throw new ApplicationError(responseJson["error"]["message"]);
    }
    var app = new MDTApplication(responseJson["data"]);

    app.appIcon= applicationIcon(app.uuid);
    return app;
  }

  Future<MDTApplication> getApplication(String appId) async {
    var url = '${mdtServerApiRootUrl}${appPath}/app/$appId';

    var response = await sendRequest('GET', url);
    var responseJson = parseResponse(response);

    if (responseJson["error"] != null) {
      throw new ApplicationError(responseJson["error"]["message"]);
    }
    var appFound = responseJson["data"];
    if (appFound != null) {
      var app = new MDTApplication(appFound);
      app.appIcon = applicationIcon(app.uuid);
      return app;
    }

    throw new ApplicationError("Unable to parse response ${responseJson}");
  }

  static String applicationIcon(String appid){
    return "${mdtServerApiRootUrl}${inPath}/app/${appid}/icon";
  }

  Future<List<MDTApplication>> getApplications({String platformFilter}) async {
    var url = '${mdtServerApiRootUrl}${appPath}/search';
    if (platformFilter != null) {
      url += 'platform=$platformFilter';
    }
    var response = await sendRequest('GET', url);
    var responseJson = parseResponse(response);

    if(responseJson["error"] != null) {
      throw new ApplicationError(responseJson["error"]["message"]);
    }

    var foundAppList = new List<MDTApplication>();
    var appList = responseJson["list"];
    if (appList != null) {
      for (Map app in appList) {
        var appCreated = new MDTApplication(app);
        appCreated.appIcon = applicationIcon(appCreated.uuid);
        foundAppList.add(appCreated);
      }
    }

    return foundAppList;
  }

  Future<bool> deleteApplication(MDTApplication appToDelete) async {
    var url = '${mdtServerApiRootUrl}${appPath}/app/${appToDelete.uuid}';
    var response = await sendRequest('DELETE', url);
    if (response.status == 200){
      return new Future.value(true);
    }
    return new Future.value(false);
  }
/*
  Future addAdministrator(MDTApplication app, String email) async {
    return _baseAppAdministratorManagement(app,"PUT",email);
  }

  Future deleteAdministrator(MDTApplication app, String email) async {
    return _baseAppAdministratorManagement(app,"DELETE",email);
  }

  Future _baseAppAdministratorManagement(MDTApplication app,String mode, String email) async {
    var url = '${mdtServerApiRootUrl}${appPath}/app/${app.uuid}/adminUser?adminEmail=$email';
    var response = await sendRequest(mode, url);
    var responseJson = parseResponse(response);

    if (response.status != 200){
      throw new ApplicationError("$mode administrator failed");
    }

    if(responseJson["error"] != null) {
      throw new ApplicationError(responseJson["error"]["message"]);
    }
  }*/

  Future addAdministrator(MDTApplication app, String email) async {
    var url = '${mdtServerApiRootUrl}${appPath}/app/${app.uuid}/adminUser';
    var appData = {"email": email};
    var response = await sendRequest('PUT', url,body: JSON.encode(appData));
    var responseJson = parseResponse(response);

    if (response.status != 200){
      throw new ApplicationError("Add administrator failed");
    }

    if(responseJson["error"] != null) {
      throw new ApplicationError(responseJson["error"]["message"]);
    }
  }

  Future deleteAdministrator(MDTApplication app, String email) async {
    var url = '${mdtServerApiRootUrl}${appPath}/app/${app.uuid}/adminUser?adminEmail=$email';
    var response = await sendRequest('DELETE', url);
    var responseJson = parseResponse(response);

    if(responseJson["error"] != null) {
      throw new ApplicationError(responseJson["error"]["message"]);
    }

    if (response.status != 200){
      throw new ApplicationError("delete administrator failed");
    }


  }
}