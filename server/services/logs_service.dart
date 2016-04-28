// Copyright (c) 2016, the Mobile App Distribution Tool project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:rpc/rpc.dart';
import 'user_service.dart' as userService;
import 'model.dart';
import '../config/config.dart' as config;
import '../utils/utils.dart';

@ApiClass(name: 'logs' , version: 'v1')
class LogsService {
  @ApiMethod(method: 'GET', path: 'tail/{logName}')
  Future<logResponse> allApplications(String logName, {String lines}) async{
    var numberOfLines = 150; //default
    userService.UserService.checkSysAdmin();
    if (lines != null){
      try{
        numberOfLines = max(0,int.parse(lines));
      }catch(e){
      }
    }
    try{
      String logFile = "";
      switch (logName.toLowerCase()){
        case "console":
          logFile = config.currentLoadedConfig["consoleLogFile"];
          break;
        case "activity":
          logFile = config.currentLoadedConfig["activityLogFile"];
          break;
        default:
          throw new RpcError(400,"LOG_ERROR","Invalid log Name");
      }
      return new logResponse(await loadLastLinesOfFile(logFile,numberOfLines));
    }catch(error,stack){
      manageExceptions(error,stack);
    }
  }

  Future<String> loadLastLinesOfFile(String filename,int lines) async{
    int averageLineSize = 150;
    var file = new File(filename);
    var size = await file.length();
    var logSize = lines * averageLineSize;

    var resultLines = new List<String>();
    var beginIndex  = max(0,size-logSize);
    Stream<List<int>> inputStream = await file.openRead(beginIndex, size);
    resultLines = await inputStream
        .transform(UTF8.decoder)
        .transform(new LineSplitter());
      /*  .listen((String line) {
            resultLines.add(line);
          },
          onError:(e){print("Error :$e");});*/

    //keep last "lines" lines
    //var length = await resultLines.length;
    //resultLines = resultLines.sublist(max(length - lines,0));

    return  resultLines.join('\n' );
  }
}