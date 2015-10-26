import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

var lastAuthorizationHeader = '';
var baseUrlHost = 'http://localhost';

Map allHeaders({String contentType : 'application/json'}){
  var initialHeaders = {HttpHeaders.CONTENT_TYPE: contentType,HttpHeaders.ACCEPT:'application/json'};
  if (lastAuthorizationHeader.length > 0){
    initialHeaders['authorization'] = lastAuthorizationHeader;
  }
  return initialHeaders;
}

Map parseResponse(http.Response response){
  return JSON.decode(response.body);
}

Future<http.Response> sendRequest(String method, String path, {String query, String body,String contentType}) {
  var url = '$baseUrlHost$path';
  if (query != null){
    url = '$url$query';
  }
  var headers = contentType == null? allHeaders(): allHeaders(contentType:contentType);
  switch (method) {
    case 'GET':
      return http.get(url,headers:allHeaders(contentType:contentType));
    case 'POST':
      var httpBody = body;
      if (body ==null) {
        httpBody ='';
      }
      return http.post(url,headers:headers,body:httpBody);
    case 'PUT':
      return http.put(url,headers:headers,body:httpBody);
    case 'DELETE':
      return http.delete(url,headers:headers);
  }

  return null;
}
/*
main() async {
  var url = 'http://httpbin.org/';
  var response = await http.get(url);
  print("Response status: ${response.statusCode}");
  print("Response body: ${response.body}");
}

import 'package:http/http.dart' as http;

main() async {
  var url = 'http://httpbin.org/post';
  var response = await http.post(url, body: 'name=doodle&color=blue');
  print("Response status: ${response.statusCode}");
  print("Response body: ${response.body}");
}


Future<HttpApiResponse> _sendRequest(String method, String path,
                                     {String api: 'testAPI/v1/', extraHeaders: const {},
                                     String query: '', body, List<Cookie> cookies}) {
  var headers = {'content-type': 'application/json'};
  headers.addAll(extraHeaders);
  var bodyStream;
  if ((method == 'POST' || method == 'PUT') && body != 'empty') {
    bodyStream = new Stream.fromIterable([UTF8.encode(JSON.encode(body))]);
  } else {
    bodyStream = new Stream.fromIterable([]);
  }
  assert(query.isEmpty || query.startsWith('?'));
  Uri uri = Uri.parse('http://server/$api$path$query');
  path = '$api$path';
  var request =
  new HttpApiRequest(method, uri, headers, bodyStream, cookies: cookies);
  return _apiServer.handleHttpApiRequest(request);
}*/