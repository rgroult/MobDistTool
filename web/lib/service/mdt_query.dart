import 'package:angular/angular.dart';
import 'dart:async';
import "dart:html";
import 'dart:convert';
import '../model/errors.dart';
import '../model/mdt_model.dart';

//final String mdtServerApiRootUrl = "http://localhost:8080/api";
String mdtServerApiRootUrl = const String.fromEnvironment('mode') == 'javascript' ? "/api" : "http://localhost:8080/api";
final String appVersion = "v1";
final String appPath = "/applications/${appVersion}";
final String artifactsPath = "/art/${appVersion}";
final String inPath = "/in/${appVersion}";
final String usersPath = "/users/${appVersion}";

enum Platform { ANDROID, IOS, OTHER }

@Injectable()
class MDTQueryService {
  Http _http;
  var lastAuthorizationHeader = '';

  void setHttpService(Http http,LocationWrapper location) {
    this._http = http;
   /* var currentLocation = location.location.href;
    if (mdtServerApiRootUrl.matchAsPrefix("/api") != null){
      Uri currentUrl = Uri.parse(currentLocation);
      mdtServerApiRootUrl = "${currentUrl.scheme}://${currentUrl.host}:${currentUrl.port}${mdtServerApiRootUrl}";
    }*/
  }
  HttpInterceptors interceptors;

  void configureInjector(HttpInterceptors _interceptors){
    interceptors = _interceptors;
    var headerInterceptor = new HttpInterceptor();
    headerInterceptor.request = (HttpResponseConfig request) {
      if (lastAuthorizationHeader.length>0 && mdtServerApiRootUrl.matchAsPrefix(request.url) != null){
        print("Add authoriztion to url ${request.url}");
        request.headers['authorization'] = lastAuthorizationHeader;
      }
      return request;
    };
    headerInterceptor.response = (HttpResponse response){
      if (response.status == 401) {
        lastAuthorizationHeader = '';
      }
      var newHeader = response.headers('authorization');
      if (newHeader != null) {
        lastAuthorizationHeader = newHeader;
      }
      return response;
    };

    interceptors.add(headerInterceptor);
  }



  MDTQueryService() {
    print("MDTQueryService constructor, mode ${const String.fromEnvironment('mode')} base URL $mdtServerApiRootUrl");
  }

  Map allHeaders({String contentType}) {
    var requestContentType =
        contentType != null ? contentType : 'application/json; charset=utf-8';
    var initialHeaders = {
      "content-type": requestContentType,
      "accept": 'application/json' /*,"Access-Control-Allow-Headers":"*"*/
    };
  /*  if (lastAuthorizationHeader.length > 0) {
      initialHeaders['authorization'] = lastAuthorizationHeader;
    } else {
      initialHeaders.remove('authorization');
    }*/
    return initialHeaders;
  }

  void checkAuthorizationHeader(HttpResponse response) async {
    return;
    if (response.status == 401) {
      lastAuthorizationHeader = '';
      throw new LoginError();
    }
/*
    var newHeader = response.headers('authorization');
    print("auth Header $newHeader");
    if (newHeader != null) {
      lastAuthorizationHeader = newHeader;
    }*/
  }

  Map parseResponse(HttpResponse response,{checkAuthorization:true}) {
    if (checkAuthorization) {
      checkAuthorizationHeader(response);
    }

    var responseData = response.data;
    if (response.data is Map) {
      return responseData;
    }
    return JSON.decode(response.data);
  }

  Future<HttpResponse> sendRequest(String method, String url,
      {String query, String body, String contentType}) async {
    //var url = '$baseUrlHost$path';
    Http http = this._http;
    if (query != null) {
      url = '$url$query';
    }
    var headers = contentType == null
        ? allHeaders()
        : allHeaders(contentType: contentType);
    var httpBody = body;
    if (body == null) {
      httpBody = '';
    }
    try {
      switch (method) {
        case 'GET':
          return await http.get(url,
              headers: allHeaders(contentType: contentType));
        case 'POST':
          return await http.post(url, httpBody, headers: headers);
        case 'PUT':
          return await http.put(url, httpBody, headers: headers);
        case 'DELETE':
          return await http.delete(url, headers: headers);
      }
    } catch (e) {
      print("error $e");
      return e;
    }
    return null;
  }

  Future<Map> registerUser(String username, String email, String password) async {
    String url = "${mdtServerApiRootUrl}${usersPath}/register";
    var userRegistration = {
      "email": "$email",
      "password": "$password",
      "name": "$username"
    };
    var response =
        await sendRequest('POST', url, body: JSON.encode(userRegistration));
    var responseJson = parseResponse(response);

    if (responseJson["error"] != null) {
      throw new RegisterError(responseJson["error"]["message"]);
    }
    return responseJson;
  }

  Future<Map> loginUser(String email, String password) async {
    String url = '${mdtServerApiRootUrl}${usersPath}/login';
    var userLogin = {"email": "$email", "password": "$password"};
    var response = await sendRequest('POST', url,
        body: 'username=${email}&password=${password}',
        contentType: 'application/x-www-form-urlencoded');
    var responseJson = parseResponse(response);

    return responseJson;
  }

  Future<MDTApplication> createApplication(
      String name, String description, String platform, String icon) async {
    var appData = {
      "name": name,
      "description": description,
      "platform": platform,
      "base64IconData":icon
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
      String appId, String name, String description, String icon) async {
    var appData = {"name": name, "description": description};
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

  String applicationIcon(String appid){
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

  Future<List<MDTArtifact>> listLatestArtifacts(String appId) async {
    var url = '${mdtServerApiRootUrl}${appPath}/app/${appId}/versions/last';

    print("Loads latest version url $url");

    var response = await sendRequest('GET', url);
    var responseJson = parseResponse(response);

    if (responseJson["error"] != null) {
      throw new ApplicationError(responseJson["error"]["message"]);
    }

    var artifactsList = new List<MDTArtifact>();

    var artList = responseJson["list"];
    if (artList != null) {
      for (Map app in artList) {
        artifactsList.add(new MDTArtifact(app));
      }
    }

    return artifactsList;
  }

  Future<List<MDTArtifact>> listArtifacts(String appId, {int pageIndex, int limitPerPage,String branch}) async{
    var url = '${mdtServerApiRootUrl}${appPath}/app/${appId}/versions';
    var parameters ={};
    if (pageIndex != null ){
      parameters["pageIndex"] = pageIndex;
    }
    if (limitPerPage != null ){
      parameters["limitPerPage"] = limitPerPage;
    }
    if (branch != null ){
      parameters["branch"] = branch;
    }
    var separator = "?";
    parameters.forEach((k,v){url+="$separator$k=$v";separator="&";});
    print("Loads version url $url");

    var response = await sendRequest('GET', url);
    var responseJson = parseResponse(response);

    if (responseJson["error"] != null) {
      throw new ApplicationError(responseJson["error"]["message"]);
    }

    var artifactsList = new List<MDTArtifact>();

    var artList = responseJson["list"];
    if (artList != null) {
      for (Map app in artList) {
        artifactsList.add(new MDTArtifact(app));
      }
    }

    return artifactsList;
  }

  Future<MDTArtifact> addArtifact(String apiKey, File file, String name,
      {bool latest,
      String branch,
      String version,
      String jsonTags,
      String sortIdentifier}) async {
    if ((apiKey == null) || (file == null) || (name == null)) {
      throw new ArtifactsError("Bad parameters");
    }
    var url = '${mdtServerApiRootUrl}${inPath}/artifacts/${apiKey}';
    if (latest) {
      url = '$url/last/$name';
    } else {
      if ((branch == null) || (version == null)) {
        throw new ArtifactsError("Bad parameters, missing branch or version");
      }
      url = '$url/$branch/$version/$name';
    }

    var formData = new FormData();
    formData.appendBlob("artifactFile", file);
    if (sortIdentifier != null) {
      formData.append("sortIdentifier", sortIdentifier);
    }

    if (jsonTags != null) {
      formData.append("jsonTags", jsonTags);
    }
    var response = await HttpRequest.request(url, method: "POST", sendData: formData);

    var responseJson = JSON.decode(response.response);
    //parseResponse(response.response,checkAuthorization:false);

    if (responseJson["error"] != null) {
      throw new ArtifactsError(responseJson["error"]["message"]);
    }
    var artifact = responseJson["data"];
    if (artifact != null) {
      return new MDTArtifact(artifact);
    }

    throw new ArtifactsError("Unable to parse response ${responseJson}");
  }

  Future<Map> artifactDownloadInfo(String artifactId) async {
    var url = '${mdtServerApiRootUrl}${artifactsPath}/artifacts/${artifactId}/download';
    var response = await sendRequest('GET', url);
    var responseJson = parseResponse(response);

    if (responseJson["error"] != null) {
      throw new ArtifactsError(responseJson["error"]["message"]);
    }
    return responseJson["data"];
  }

  Future<bool> deleteArtifact(String artifactId) async {
    var url = '${mdtServerApiRootUrl}${artifactsPath}/artifacts/${artifactId}';
    var response = await sendRequest('DELETE', url);
    if (response.status == 200){
      return new Future.value(true);
    }
    return new Future.value(false);
  }

  Future<bool> downloadArtifact(String artifactId) async {
    var downloadInfos = await artifactDownloadInfo(artifactId);
    if (downloadInfos != null){
      var url = '${mdtServerApiRootUrl}${downloadInfos["directLinkUrl"]}';
      sendRedirect(url);
    }
  }

  Future<bool> InstallArtifact(String artifactId) async {
    var downloadInfos = await artifactDownloadInfo(artifactId);
    if (downloadInfos != null){
      var url = '${downloadInfos["installUrl"]}';
      print('redirect :$url, map ${downloadInfos.toString()}');
      sendRedirect(url);
    }
  }

  void sendRedirect(String url){
    AnchorElement tl = document.createElement('a');
    tl..attributes['href'] = url
    // ..attributes['download'] = filename
      ..click();
  }
}
