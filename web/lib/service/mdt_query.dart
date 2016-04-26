import 'package:angular/angular.dart';
import 'dart:async';
import "dart:html";
import 'dart:convert';
import '../model/errors.dart';
import 'src/mdt_conf_query.dart';
import 'src/mdt_interceptors_query.dart';
import 'src/mdt_users_query.dart';
import 'src/mdt_applications_query.dart';
import 'src/mdt_artifacts_query.dart';

enum Platform { ANDROID, IOS, OTHER }

//final String mdtServerApiRootUrl = "http://localhost:8080/api";


/* var currentLocation = location.location.href;
    if (mdtServerApiRootUrl.matchAsPrefix("/api") != null){
      Uri currentUrl = Uri.parse(currentLocation);
      mdtServerApiRootUrl = "${currentUrl.scheme}://${currentUrl.host}:${currentUrl.port}${mdtServerApiRootUrl}";
    }*/


abstract class MDTQueryServiceAware {
  void loginExceptionOccured();
}

@Injectable()
class MDTQueryService extends MDTQueryServiceHttpInterceptors with MDTQueryServiceUsers,MDTQueryServiceApplications,MDTQueryServiceArtifacts{
 Http _http;
 MDTQueryServiceAware _mdtQueryServiceAware;
  void setHttpService(MDTQueryServiceAware mdtQueryServiceAware,Http http,LocationWrapper location) {
    this._http = http;
    this._mdtQueryServiceAware = mdtQueryServiceAware;
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

  Future checkAuthorizationHeader(HttpResponse response) async {
    if (response.status == 401) {
      //return to home / login
      if (_mdtQueryServiceAware != null){

        _mdtQueryServiceAware.loginExceptionOccured();
      }
    }
    return;
    /*if (response.status == 401) {
      lastAuthorizationHeader = '';
      throw new LoginError();
    }*/
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
      print("send request error $e");
      if (e.status == 0){
        throw new ConnectionError();
      }
      return e;
    }
    return null;
  }

 void sendRedirect(String url){
   AnchorElement tl = document.createElement('a');
   tl..attributes['href'] = url
   // ..attributes['download'] = filename
     ..click();
 }

  //server logs
  Future<String> loadLogs(String logName,{int maxLines}) async{
    String url = "${mdtServerApiRootUrl}/logs/v1/tail/${logName}";
    if (maxLines != null ){
      url = "${url}?lines=$maxLines";
    }
    var response = await sendRequest('GET', url);
    var responseJson = parseResponse(response);

    if (responseJson["error"] != null) {
      throw new BaseError(responseJson["error"]["message"]);
    }

    return responseJson["data"];
  }

}
