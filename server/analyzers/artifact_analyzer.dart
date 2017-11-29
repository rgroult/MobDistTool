// Copyright (c) 2016, the Mobile App Distribution Tool project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:plist/plist.dart' as plist;
import '../managers/errors.dart';
import '../config/config.dart' as config;
//import 'package:apk_parser/apk_parser.dart';

Future<Map> analyzeAndExtractArtifactInfos(File fileToAnalyze,String platform) async{
  switch (platform.toLowerCase()){
    case "ios":
      return analyzeAndExtractIOSArtifactInfos(fileToAnalyze,useSystemUnzip:"true"==config.currentLoadedConfig[config.MDT_IPA_EXTRACT_USING_UNZIP]);
    case "android":
      return analyzeAndExtractAndroidArtifactInfos(fileToAnalyze);
    default:
      throw new ArtifactError("incorrect artifact for platform");
  }
}

final List<String> iosPlistKeysToExtract = ["CFBundleIdentifier","CFBundleVersion","MinimumOSVersion","CFBundleShortVersionString"];

Future<Map> analyzeAndExtractIOSArtifactInfos(File fileToAnalyze,{bool useSystemUnzip:false}) async{
  try {
    //decode ipa
    var plistString = null;
    List<int> plistBytesInfo = null;
    if (useSystemUnzip) {
     // print("using System unzip on ${fileToAnalyze.path}");
      var processResult = await Process.run('unzip', ['-p','${fileToAnalyze.path}','*.app/Info.plist'], runInShell:false,stdoutEncoding: null);
      if (processResult.exitCode == 0) {
        //print("OK");
        //print("out ${processResult.stdout}");
        plistBytesInfo = processResult.stdout;
        plistString = new String.fromCharCodes(plistBytesInfo);
      }
  }else {
      //print("using Dart unzip");
      //read file
      List<int> zipBytes = await fileToAnalyze.readAsBytes();
      Archive archive = new ZipDecoder().decodeBytes(zipBytes);
      plistBytesInfo = archive.firstWhere((ArchiveFile file) => file.name.contains('.app/Info.plist') == true).content;
      plistString = new String.fromCharCodes(plistBytesInfo);
    }
    //print("Unzip done");
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
        await tmpFile.writeAsBytes(plistBytesInfo);
        //decode binary plist
        var workingDirectory = await Directory.current;
        var processResult = await Process.run('perl', ['${workingDirectory.path}/server/analyzers/scripts/plutil.pl', '$tempFilePath'], runInShell:true);
        if (processResult.exitCode == 0){
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

Future<Map> analyzeAndExtractAndroidArtifactInfos(File fileToAnalyze) async {
  try {
    var fullFileToAnalyze = fileToAnalyze.path;
    var artifactInfo = {};
    var processResult = await Process.run(config.currentLoadedConfig[config.MDT_AAPT_FULL_PATH], ['d', 'xmltree', fullFileToAnalyze, 'AndroidManifest.xml']);
    var result = processResult.stdout.toString().split("\n");
    var list = new List<String>();
    result.forEach((element) => list.add(element.trim()));
    //result.forEach((element) => print(element.trim()));
    for (var i = 0; i < list.length; i++) {
      if (list.elementAt(i).startsWith("A: package")) {
        artifactInfo['PACKAGE_NAME'] =
            parsePackageInformation(list.elementAt(i));
      } else if (list.elementAt(i).startsWith("A: android:versionCode")) {
        artifactInfo['VERSION_CODE'] = parseVersionCode(list.elementAt(i));
      } else if (list.elementAt(i).startsWith("A: android:versionName")) {
        artifactInfo['VERSION_NAME'] = parseVersionName(list.elementAt(i));
      } else if (list.elementAt(i).startsWith("A: android:minSdkVersion")) {
        artifactInfo['MIN_SDK'] = parseSdkValue(list.elementAt(i));
      } else if (list.elementAt(i).startsWith("A: android:maxSdkVersion")) {
        artifactInfo['MAX_SDK'] = parseSdkValue(list.elementAt(i));
      } else if (list.elementAt(i).startsWith("A: android:targetSdkVersion")) {
        artifactInfo['TARGET_SDK'] = parseSdkValue(list.elementAt(i));
      } else {
        //print("unused element ignore it");
      }
    }
    return artifactInfo;
  } catch (e) {
    throw new ArtifactError("Unable to analyse APK");
  }
}

String parsePackageInformation(String information) {
  return parseStringValue(information);
}

String parseVersionName(String information) {
  return parseStringValue(information);
}

String parseStringValue(String information) {
  try {
   // print(information);
    var value = information.split(" ");
    var string = value.removeAt(1);
    return string.substring(string.indexOf("\"") + 1, string.lastIndexOf("\""));
  } catch (exception) {
    return null;
  }
}

String parseVersionCode(String information) {
  return parseHexValue(information);
}

String parseSdkValue(String information) {
  return parseHexValue(information);
}

String parseHexValue(String information) {
  try {
   // print(information);
    var value = information.substring(information.lastIndexOf(")") + 1);
    return int.parse(value).toString();
  } catch (formatException) {
    return null;
  }
}
