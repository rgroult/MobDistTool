import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:plist/plist.dart' as plist;
import '../managers/errors.dart';

Future<Map> analyzeAndExtractIOSArtifactInfos(File fileToAnalyze) async{
  try {
    //read file
    List<int> zipBytes = await fileToAnalyze.readAsBytes();
    //decode ipa
    Archive archive = new ZipDecoder().decodeBytes(zipBytes);
    /*for (ArchiveFile f in archive.files) {
      print('file ${f.name}');
    }*/
    List<int> ipaInfo = archive.firstWhere((ArchiveFile file) => file.name.contains('.app/Info.plist') == true).content;
    //Not used yet, Info.plist is not binary
   /* //create info.plist binary file
    var tmpDirectory = await Directory.systemTemp.createTemp('mdt');
    var tempFilePath = '${tmpDirectory.path}/Info.plist';
    var tmpFile = new File(tempFilePath);
    await tmpFile.writeAsBytes(ipaInfo);
    //decode binary plist
    var workingDirectory = await Directory.current;
    var preocessResult = await Process.run('perl', ['${workingDirectory.path}/server/analyzers/scripts/plutil.pl','$tempFilePath'],runInShell:true);
    */
    var plistString = new String.fromCharCodes(ipaInfo);
    var parsedPlist = plist.parse(plistString);

    print("result = $parsedPlist");
  }catch(e){
    throw new ArtifactError("Unable to analyse IPA");
  }


  //find Info.plist in file



  //List jpg = archive.findFile('cat.jpg').content;
}