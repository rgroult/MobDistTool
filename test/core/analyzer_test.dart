// Copyright (c) 2016, Rémi Groult.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'dart:async';
import 'dart:io';
import '../../server/analyzers/artifact_analyzer.dart' as analyzer;
import '../../server/managers/errors.dart';

void main() {
  var storage;
  test("test IOS analyzer OK", () async {
   // var file = new File(Directory.current.path+'/test/core/marmiton.ipa');
    var file = new File('/Users/gogetta/Desktop/FollowerSC2.ipa');
    var result = await analyzer.analyzeAndExtractIOSArtifactInfos(file);
    expect(result,isNotNull);
    expect(result.length,equals(3));
    print("$result");
  });

  test("test IOS analyzer KO", () async {
    var result = true;
    try {
      var file = new File(Directory.current.path + '/test/core/artifact_sample.txt');
      var tags = await analyzer.analyzeAndExtractIOSArtifactInfos(file);
      expect(tags,isNotNull);
    }catch(e){
      expect((e is ArtifactError), isTrue);
      result = false;
    }
    expect(result,isFalse);

  });

  test("test Android analyzer OK", () async {
    var file = new File("/Users/shallay/Desktop/dev/test_dart/bin/MyOfficePhone-prod_1.0.3_RC1_releaseSigned.apk");
    var result = await analyzer.analyzeAndExtractArtifactInfos(file, "android");
    expect(result,isNotNull);
    //expect(result.length,equals(3));
    print("$result");
  });

  test("test Android analyzer KO : bad OS", () async {
    var result = true;
    try {
      var file = new File("/Users/shallay/Desktop/dev/test_dart/bin/MyOfficePhone-prod_1.0.3_RC1_releaseSigned.apk");
      var tags = await analyzer.analyzeAndExtractArtifactInfos(file, "ios");
      expect(tags,isNotNull);
    }catch(e){
      expect((e is ArtifactError), isTrue);
      result = false;
    }
    expect(result,isFalse);
  });

  test("test Android analyzer KO : file not found", () async {
    var result = true;
    try {
      var file = new File(Directory.current.path + '/test/core/artifact_sample.txt');
      var tags = await analyzer.analyzeAndExtractArtifactInfos(file, "android");
      expect(tags,isNotNull);
    }catch(e){
      expect((e is ArtifactError), isTrue);
      result = false;
    }
    expect(result,isFalse);
  });

}