import 'package:shelf_auth/shelf_auth.dart';
import 'dart:io';
import 'package:rpc/rpc.dart';
import '../model/model.dart';

class User extends Principal {
  MDTUser dbUser;
  User(MDTUser user ):super(user.email){
     this.dbUser = user;
  }
}

class Response {
  int status;
  Map<String,String> data;
  Response(this.status,this.data);
}

class DownloadInfo {
  String downloadUrl;
  String token;
}

class ResponseList {
  int status;
  List<Map<String,String>> list;
  ResponseList(this.status,this.list);
}

class OKResponse extends Response {
  OKResponse():super(200,{});
}

class NotApplicationAdministrator extends RpcError {
  NotApplicationAdministrator():super(401, 'APPLICATION_ERROR', 'You are not administrator on this app');
}

class ArtifactMsg {
  @ApiProperty(required: true)
  MediaMessage artifactFile;
  @ApiProperty(required: false)
  String sortIdentifier;
  @ApiProperty(required: false)
  String jsonTags;
}

class FullArtifactMsg {
  @ApiProperty(required: true)
  String branch;
  @ApiProperty(required: true)
  String version;
  @ApiProperty(required: true)
  String artifactName;
  @ApiProperty(required: false)
  MediaMessage artifactFile;
  @ApiProperty(required: false)
  String sortIdentifier;
  @ApiProperty(required: false)
  String jsonTags;
}

