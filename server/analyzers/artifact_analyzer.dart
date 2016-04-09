// Copyright (c) 2016, the Mobile App Distribution Tool project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:plist/plist.dart' as plist;
import '../managers/errors.dart';
import 'package:apk_parser/apk_parser.dart';

Future<Map> analyzeAndExtractArtifactInfos(File fileToAnalyze,String platform) async{
  switch (platform.toLowerCase()){
    case "ios":
      return analyzeAndExtractIOSArtifactInfos(fileToAnalyze);
    case "android":
      return analyzeAndExtractAndroidArtifactInfos(fileToAnalyze);
    default:
      throw new ArtifactError("incorrect artifact for platform");
  }
}

final List<String> iosPlistKeysToExtract = ["CFBundleIdentifier","CFBundleVersion","MinimumOSVersion","CFBundleShortVersionString"];

Future<Map> analyzeAndExtractIOSArtifactInfos(File fileToAnalyze) async{
  try {
    //read file
    List<int> zipBytes = await fileToAnalyze.readAsBytes();
    //decode ipa
    Archive archive = new ZipDecoder().decodeBytes(zipBytes);
    List<int> ipaInfo = archive.firstWhere((ArchiveFile file) => file.name.contains('.app/Info.plist') == true).content;
    var plistString = new String.fromCharCodes(ipaInfo);
    var parsedPlist = null;
    try{
      parsedPlist= plist.parse(plistString);
    }catch(e){
    }
    if (parsedPlist == null){
        //save info.plist binary file
        var tmpDirectory = await Directory.systemTemp.createTemp('mdt');
        var tempFilePath = '${tmpDirectory.path}/Info.plist';
        var tmpFile = new File(tempFilePath);
        await tmpFile.writeAsBytes(ipaInfo);
        //decode binary plist
        var workingDirectory = await Directory.current;
        var preocessResult = await Process.run('perl', ['${workingDirectory.path}/server/analyzers/scripts/plutil.pl', '$tempFilePath'], runInShell:true);
        if (preocessResult.exitCode == 0){
          tempFilePath = '${tmpDirectory.path}/Info.text.plist';
          plistString = await new File(tempFilePath).readAsString();
          parsedPlist= plist.parse(plistString);
        }
    }


    var plistTags ={};
    for (String key in iosPlistKeysToExtract) {
      plistTags[key] = parsedPlist[key];
    }

    return plistTags;
  }catch(e){
    throw new ArtifactError("Unable to analyse IPA");
  }
}

Future<Map> analyzeAndExtractAndroidArtifactInfos(File fileToAnalyze) async{
  try {
    List<int> bytesApk = await fileToAnalyze.readAsBytes();
    var artifactInfo = {};
    Manifest manifest = await parseManifest(bytesApk);
    artifactInfo['PACKAGE_NAME'] = manifest.package;
    artifactInfo['MIN_SDK'] = manifest.usesSdk.minSdkVersion;
    artifactInfo['VERSION_CODE'] = manifest.versionCode;
    artifactInfo['VERSION_NAME'] = manifest.versionName;
    if (manifest.usesSdk.maxSdkVersion != null) {
      artifactInfo['MAX_SDK'] = manifest.usesSdk.maxSdkVersion;
    }
    if (manifest.usesSdk.targetSdkVersion != null) {
      artifactInfo['TARGET_SDK'] = manifest.usesSdk.targetSdkVersion;
    }

    //print(manifest);
    return artifactInfo;
  }catch(e){
    throw new ArtifactError("Unable to analyse APK");
  }

}