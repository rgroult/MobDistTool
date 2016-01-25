import 'dart:async';
import 'dart:io';
import '../../errors.dart';

class BaseStorageManager {
  String storageIdentifier = "BaseStorageManager";

  String generateStorageInfos(String storageId){
    return "${storageIdentifier}://$storageId";
  }

  String _extractStorageId(String storageInfo){
    var regexp = new RegExp('^${storageIdentifier}://(.+)');
    var match = regexp.matchAsPrefix(storageInfo);
    if (match == null){
      throw new ArtifactError('Storage unable to handle this Url');
    }
    return match[1];
  }

  Future<String> storeFile(File file, {String filename, String contentType}) async {
    throw new ArtifactError('Not implemented');
  }

  Future<Stream> getStreamFromStoredFile(String storedInfos) async{
    throw new ArtifactError('Not implemented');
  }

  Future<bool> deleteStoredFile(String storedInfos) async{
    throw new ArtifactError('Not implemented');
  }

  Future<Uri> storageUrI(String infos)async {
    throw new ArtifactError('Not implemented');
  }
}
