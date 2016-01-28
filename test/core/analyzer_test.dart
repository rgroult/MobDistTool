import 'package:test/test.dart';
import 'dart:async';
import 'dart:io';
import '../../server/analyzers/ios_artifact_analyzer.dart' as ios;

void main() {
  var storage;
  test("test IOS analyzer", () async {
    var file = new File(Directory.current.path+'/test/core/marmiton.ipa');
    var result = await ios.analyzeAndExtractIOSArtifactInfos(file);
    print("$result");
  });
}