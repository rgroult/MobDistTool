// Copyright (c) 2016, the Mobile App Distribution Tool project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:math';
import 'package:crypto/crypto.dart' as crypto;
import 'package:rpc/rpc.dart';
import "package:log4dart/log4dart_vm.dart";
import '../config/config.dart' as config;

final _logger = LoggerFactory.getLogger("RPC");

String randomString(int length) {
  var rand = new Random();
  var codeUnits = new List.generate(
      length,
      (index){
    return rand.nextInt(33)+89;
  }
  );
  return new String.fromCharCodes(codeUnits);
}


String generateHash(String stringToHash) {
  var md5 = new crypto.MD5();
  md5.add(stringToHash.codeUnits);
  var hash = crypto.CryptoUtils.bytesToHex(md5.close());
  return hash;
}


void manageExceptions(dynamic error,StackTrace stack){
  if (error is Error){
    _logger.error("${error.toString()}:\n $stack");
    throw  new InternalServerError();
  }
  _logger.info("${error.toString()}");
  throw error;
}

void printAndLog(String msg){
  var outputToConsole = config.currentLoadedConfig[config.MDT_LOG_TO_CONSOLE] == "true";
  if (!outputToConsole){
    print(msg);
  }
  _logger.info(msg);
}
