import 'package:angular/angular.dart';
import 'dart:async';
import 'dart:convert';

final String mdtServerApiRootUrl = "http://localhost:8080/api";
final String appVersion = "v1";
final String appPath = "/applications/${appVersion}";

@Injectable()
class MDTQueryService {
  Http _http;
  var lastAuthorizationHeader = '';

  void setHttpService(Http http){
    this._http = http;
  }

  MDTQueryService() {
    print("MDTQueryService constructor");
  }

  Map allHeaders({String contentType}){
    var requestContentType = contentType!=null ? contentType : 'application/json; charset=utf-8';
    var initialHeaders = {"content-type": requestContentType,"accept":'application/json'/*,"Access-Control-Allow-Headers":"*"*/};
    if (lastAuthorizationHeader.length > 0){
      initialHeaders['authorization'] = lastAuthorizationHeader;
    }else {
      initialHeaders.remove('authorization');
    }
    return initialHeaders;
  }

  void checkAuthorizationHeader(http.Response response){
    var newHeader = response.headers['authorization'];
    if (newHeader != null) {
      lastAuthorizationHeader = newHeader;
    }else {
      lastAuthorizationHeader = '';
    }
  }

  Map parseResponse(http.Response response){
    checkAuthorizationHeader(response);
    return JSON.decode(response.body);
  }

  http.Response sendRequest(String method, String url, {String query, String body,String contentType}) async {
    //var url = '$baseUrlHost$path';
    Http http = this._http;
    if (query != null){
      url = '$url$query';
    }
    var headers = contentType == null? allHeaders(): allHeaders(contentType:contentType);
    var httpBody = body;
    if (body ==null) {
      httpBody ='';
    }
    try{
      switch (method) {
        case 'GET':
          return await http.get(url,headers:allHeaders(contentType:contentType));
        case 'POST':
          return await http.post(url,httpBody,headers:headers);
        case 'PUT':
          return await http.put(url,httpBody,headers:headers);
        case 'DELETE':
          return await http.delete(url,headers:headers);
      }
    } catch (e) {
      print("error $e");
      return e;
    }
    return null;
  }

  void loginUser(String email, String password) async {
  /*  String url = "${scope.rootScope.context.mdtServerApiRootUrl}/users/v1/login";
    var userLogin = {"email":"$email", "password":"$password"};
    isHttpLoading = true;
    var response =  await mainComp().sendRequest('POST', url, body:'username=${email}&password=${password}', contentType:'application/x-www-form-urlencoded');
    if (response.status == 200){
      //hide popup
      mainComp().isUserConnected= true;
      mainComp().currentUser = response.responseText["data"];
      mainComp().hidePopup();
      locationService.router.go('apps',{});
    }else  if (response.status == 401){
      isCollapsed = false;
      errorMessage = "Login failed, Bad login or password.";
    }else {
      isCollapsed = false;
      if (response.status == 0){
        errorMessage = "Login failed, Error :${response}";
      }else {
        errorMessage = "Login failed, Error :${response.responseText}";
      }
    }*/
  }

  void createApplication(String name, String description, String platform, String icon) async{
    var appData = {"name":name, "description":description, "platform":platform};
    var response = await sendRequest('POST', '${mdtServerApiRootUrl}${appPath}/create', body: JSON.encode(appData));
    var responseJson = parseResponse(response);

  }
}