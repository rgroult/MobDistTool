// Copyright (c) 2016, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

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
  String directLinkUrl;
  String installUrl;
  //String installScheme;
  Map toJson(){
    var result = {};
    if (directLinkUrl != null){
      result["directLinkUrl"] = directLinkUrl;
    }
    if (installUrl != null){
      result["installUrl"] = installUrl;
    }
 /*   if (installScheme != null){
      result["installScheme"] = installScheme;
    }*/
    return result;
  }
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

class UpdateApplication {
  @ApiProperty(required: false)
  String name;
  @ApiProperty(required: false)
  String description;
  @ApiProperty(required: false)
  String platform;
  @ApiProperty(required: false)
  String base64IconData;
  UpdateApplication();
}
class CreateApplication {
  @ApiProperty(required: true)
  String name;
  @ApiProperty(required: true)
  String description;
  @ApiProperty(required: true)
  String platform;
  @ApiProperty(required: false)
  String base64IconData;
  CreateApplication();
}

class AddAdminUserMessage{
  @ApiProperty(required: false)
  String email;
}

class ActivationMessage{
  @ApiProperty(required: true)
  String activationToken;
}