import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:plist/plist.dart' as plist;
import '../managers/errors.dart';

Future<Map> analyzeAndExtractArtifactInfos(File fileToAnalyze,String platform) async{
  switch (platform.toLowerCase()){
    case "ios":
      return analyzeAndExtractIOSArtifactInfos(fileToAnalyze);
    case "android":
      //TO DO
      return {};
    default:
      throw new ArtifactError("incorrect artifact for platform");
  }
}


final String TAG_BUNDLE_ID = 'MDT_IOS_BUNDLE_ID';
final String TAG_BUNDLE_VERSION = 'MDT_IOS_BUNDLE_VERSION';
final String TAG_MINIMUM_OS_VERSION = 'MDT_IOS_MINIMUM_OS_VERSION';

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
    plistTags[TAG_BUNDLE_ID] = parsedPlist["CFBundleIdentifier"];
    plistTags[TAG_BUNDLE_VERSION] = parsedPlist["CFBundleVersion"];
    plistTags[TAG_MINIMUM_OS_VERSION] = parsedPlist["MinimumOSVersion"];

    return plistTags;
  }catch(e){
    throw new ArtifactError("Unable to analyse IPA");
  }
}