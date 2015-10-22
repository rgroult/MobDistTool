import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

var lastAuthorizationHeader = '';
var baseUrlHost = 'http://localhost';

Map allHeaders(){
  var initialHeaders = {'content-type': 'application/json'};
  if (lastAuthorizationHeader.length > 0){
    initialHeaders['authorization'] = lastAuthorizationHeader;
  }

}

Map parseResponse(Response response){
  return JSON.decode(response.body);
}

Future<Response> sendRequest(String method, String path, {String query, String body}) {
  var url = '$baseUrlHost$path';
  if (query != null){
    url = '$url$query';
  }
  switch (method) {
    case 'GET':
      return http.get(url,headers:allHeaders());
    case 'POST':
      var httpBody = body;
      if (body ==null) {
        httpBody ='';
      }
      return http.post(url,headers:allHeaders(),body:httpBody);
    case 'PUT':
      return http.put(url,headers:allHeaders(),body:httpBody);
    case 'DELETE':
      return http.delete(url,headers:allHeaders());
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