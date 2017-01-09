import 'package:angular2/core.dart';
import 'package:http/browser_client.dart';
import 'package:http/src/base_request.dart';
import 'package:http/src/byte_stream.dart';
import 'package:http/src/exception.dart';
import 'package:http/src/streamed_response.dart';
import 'dart:async';
import 'mdt_conf_query.dart';
import '../global_service.dart';

class MDTHttpClient extends BrowserClient {
  var _lastAuthorizationHeader = '';

  Future<StreamedResponse> send(BaseRequest request) async {
    //Add authorization header if needed
    var mustManageAuthorization = mdtServerApiRootUrl.matchAsPrefix(request.url.toString()) != null;
    if (mustManageAuthorization &&_lastAuthorizationHeader.length>0 ){
      print("Add authoriztion to url ${request.url}");
      request.headers['authorization'] = _lastAuthorizationHeader;
    }

    var response = await super.send(request);
    //parse authorization header if needed
    if (mustManageAuthorization) {
      if (response.statusCode == 401) {
        _lastAuthorizationHeader = '';
      }else {
        var newHeader = response.headers['authorization'];
        if (newHeader != null) {
          _lastAuthorizationHeader = newHeader;
        }
      }
    }
    return new Future.value(response);
  }
}
