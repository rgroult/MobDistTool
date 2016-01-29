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
    }catch(e){
      expect((e is ArtifactError), isTrue);
      result = false;
    }
    expect(result,isFalse);
  });
}