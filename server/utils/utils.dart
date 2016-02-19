// Copyright (c) 2016, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:math';

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