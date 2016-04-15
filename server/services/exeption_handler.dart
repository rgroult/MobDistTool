// Copyright (c) 2016, the Mobile App Distribution Tool project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:io' show HttpHeaders;
import 'dart:async';
import 'package:shelf/shelf.dart' as shelf;
import 'package:http_exception/http_exception.dart';
export 'package:shelf_exception_handler/shelf_exception_handler.dart';
import 'package:shelf_response_formatter/shelf_response_formatter.dart';
import "package:log4dart/log4dart_vm.dart";

final _logger = LoggerFactory.getLogger("exceptionHandler");
ResponseFormatter formatter = new ResponseFormatter();

shelf.Middleware exceptionHandler() {
  return (shelf.Handler handler) {
    return (shelf.Request request) {
      return new Future.sync(() => handler(request))
          .then((response) => response)
          .catchError((error, stackTrace) {
        FormatResult result;
        switch(error.status){
          case 401:
            //return only "unauthorized"
            result = formatter.formatResponse(request,{"code":401, "message":"Unauthorized"});
            break;
     /*     case 500:
            result = formatter.formatResponse(request,{"code":500, "message":"Internal Server Error"});
            break;*/
          default:
            result = formatter.formatResponse(request, error.toMap());
            print("error ${error.toMap()}");
            break;
        }
        _logger.error(result.body);

        //print("error ${error.toMap()}");
      //  FormatResult
        return new shelf.Response(error.status,
            body: result.body,
            headers: {HttpHeaders.CONTENT_TYPE: result.contentType});
      }, test: (e) => e is HttpException);
    };
  };
}