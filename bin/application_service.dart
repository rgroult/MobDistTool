import 'dart:io';

import 'package:rpc/rpc.dart';
import 'package:rpc/src/context.dart' as context;

@ApiClass(name: 'apps' , version: 'v1')
class ApplicationService {
  @ApiMethod(method: 'GET', path: 'all')
  AppResponse userLogin() {
    return new AppResponse()
      ..result="Hello world";
  }
}

class AppResponse {
  String result;
  AppResponse();
}