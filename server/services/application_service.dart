import 'dart:io';

import '../../packages/rpc/rpc.dart';
import '../../packages/rpc/src/context.dart' as context;

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