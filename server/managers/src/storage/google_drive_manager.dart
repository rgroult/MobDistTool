import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' show Client;
import 'package:googleapis_auth/auth_io.dart' as auth;
//import 'package:googleapis/common/common.dart' show Media, DownloadOptions;
import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' show Media, DownloadOptions;
import 'package:googleapis/drive/v2.dart' as drive;
import 'base_storage_manager.dart';
import '../../errors.dart';

// Obtain the client email / secret from the Google Developers Console by
// creating new OAuth credentials of application type
// "Installed application / Other".
final identifier = new auth.ClientId(
    "<please fill in>.apps.googleusercontent.com",
    "<please fill in>");


final accountCredentials = new auth.ServiceAccountCredentials.fromJson(r'''
{
  "type": "service_account",
  "project_id": "mobdisttool-1200",
  "private_key_id": "99d613570100ea5f8064dad617f2670cf969a44f",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCMAl/uP+8vaSTU\nBkY3TJwwLZFQaBqDhILhx/k82NZFJSLAo6wWV3gge4r7xS8o78BqJJlLGzwcRv4x\nwxTioG7dACBG03QpjaStT4Qta9m1OS2w3C6Q2fWHSAahH5yM49WYdKunZ80L0NQX\nupdw9T5/SAzTJ8RSy265E1DJwgK6q+ogzkTeWqodWal16uuv7/l76tTxL2BIpf1R\n3Hkg/k7sQFwy8+mkHY7mpYC94WtbsQqRfMf0su/26A7UnV2LDxJl5ozleu4pkAfK\nWSPUORc7cJ43GQOIUPedd+BmNktQFa0eXmrmkuLJhzI822j9LP99CQ74I3AZvigY\nRkuED/PdAgMBAAECggEAdecGC+dRL7a2acpC1QyxtqyY44JXWYt8gE/bZk8f2aiV\nJG5wW3wbUBdZif2aYjnL6laZtLLhotpx80vZyaLa2Ubi52HoP5nlJIGCyJE7C65z\n+Kzild7GMb8IviSVu9udIr6VUutJs/qOsNDT+S69C4iMLEEfxa1Et5w5ez3i+HjO\nM/pAFhMqm/Hf8MOof8rqDacvq1rTBoIeHENe0PMspvGHtB456k1LmUa23n8CAY3/\n+oc3GA/3J0cZQgq7gT9PpMnyerse9JJzsbowOmUT7qEa9URQPqSvdsK7vpwHJV9J\nM4Jcg3jVc1FjgmcYjWPiWWY5B+6f2NMFjc4AUvXGDQKBgQDUpho4/4O8FBuMSuDb\nh9IfcApudXfekxE4HcVz9qJxS2RAEj4pCdyAEwMCGrz3AKip1pNqTa+YY8ZLTwRv\nk+IWRsmYU2WcnJ6NH76CzXlGzFzSB5kRg+JccR/9Z9IzfK85RZqet6u7QSjoPqwA\nZYDiFI1ghCy2+x/Gc0EKlVdWRwKBgQCojUwgnOCfEDZThTTVn+usCb8PqPRxON8e\nok9rrVplqzi7BSu/wYFKBZ1Am96gk9Ppqfhym7tQFQ7dFHY68Xr5ZyEdbKDeKXr8\nGLrNdiTa/PLry8Es+8R4i0C+Cn6BpPmcEHxc6vIdpalvbDu5acyTuUaU0u+o2GU7\nZ53huH2iuwKBgEQRTz+DerWPcin8JfHfjgEGKjClZVNXnCFsVjICdojxawufS0pz\nn6NXcpUP3gDqsxJ6XwGeEGElPuoIRxE4MxySWCFsQJBbCd1+lcrk3rcs32FTkUmr\n/587jtPckcptVOFuSEoZ3Ny5xNBij0gpNZIopgCJDo8b31X0upMarrQtAoGABoJm\ndT/5wMrcfj8/uhxR+rPpqA4rWpAKteEo1gy81/5T040wklhDyPsMhqk+YM80uOpy\niOKQylf12f3nTwFycV1VPxCp6cqKUGAYHsU4SSjJrOeSj00t2kXueyhmmFUpuqg8\nVU5RiWmTcJUqfU+jsfTO0AKRdODej/vBci0w1O8CgYACqs1TOG8KsejMcXz3eooD\n4Z7c6ELhjNDbRiNgw66DHpDRPEjBo0SKmNC6ZaDyJczttssnUOfp7zqR5gaTE7B1\ndMKY71/23qoZob0hOkTcZMzO/BAVZLL5ZpABHY6+w1O455iO2rEbrzg30PX22+gU\nCuUP+LyBns8LN/Z7Ey/pFw==\n-----END PRIVATE KEY-----\n",
  "client_email": "mobdisttool@mobdisttool-1200.iam.gserviceaccount.com",
  "client_id": "104717954167324583811",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://accounts.google.com/o/oauth2/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/mobdisttool%40mobdisttool-1200.iam.gserviceaccount.com"
}

''');

// This is the list of scopes this application will use.
// You need to enable the Drive API in the Google Developers Console.

class GoogleDriveStorageManager extends BaseStorageManager {
  String storageIdentifier = "gdrive";

  final scopes = [drive.DriveApi.DriveScope];
  auth.AutoRefreshingAuthClient authClient;
  var api;
  GoogleDriveStorageManager() {

  }

  Future initializeStorage(Map config)async {
    authClient = await auth.clientViaServiceAccount(accountCredentials, scopes);
    api = new drive.DriveApi(authClient);
  }

  Future<String> storeFile(File file,{String filename, String contentType}) async {
    var media = new Media(file.openRead(), file.lengthSync());
    var driveFile = new drive.File();
    if (filename != null){
      driveFile.title = filename;
    }

    if(contentType != null){
      driveFile.mimeType = contentType;
    }
    var result = await api.files.insert(driveFile, uploadMedia: media);
    if (result == null){
      throw new ArtifactError("Error on storaging file");
    }
    return generateStorageInfos(result.id);
  }

  Future<Stream> getStreamFromStoredFile(String storedInfos) async{
    String objectId= extractStorageId(storedInfos);
    drive.File file =  await api.files.get(objectId);
    var bytes = await authClient.readBytes(file.downloadUrl);
    print(new AsciiDecoder().convert(bytes));
    var tmpDirectory = await Directory.systemTemp.createTemp('mdt');
    var tmpFile = new File(objectId);
    await tmpFile.writeAsBytes(bytes,flush:true);
    return tmpFile.openRead();
/*
    .createSync(recursive:true);
    var stream = tmpFile.openWrite()..add(bytes);
    return stream;*/
  }

  Future deleteStoredFile(String storedInfos) async{
    String objectId= extractStorageId(storedInfos);
    return api.files.delete(objectId);
  }

  Future<Uri> storageUrI(String infos) async{
    throw new ArtifactError('Not supported by this storage');
  }
/*
  Future<File> storageFile(String infos) async {
    drive.File file =  await api.files.get(infos);
    var bytes = await authClient.readBytes(file.downloadUrl);
    var localfile = new File("ttstst.txt").openWrite();
    var stream = localfile.openWrite().add(bytes);
    stream.close();

    return localfile;
  }

  Future<String> storeFile(File file) async{
    var media = new Media(file.openRead(), file.lengthSync());
    var driveFile = new drive.File()
      ..title = "test";
    var result = await api.files.insert(driveFile, uploadMedia: media);

  return result.id;
  }

  Future<bool> deleteFile(File file) {
    throw new ArtifactError('Not implemented');
  }

  Future<bool> deleteFileFromInfos(String infos) {
    throw new ArtifactError('Not implemented');
  }*/
}