import 'package:angular/angular.dart';
import 'dart:core';
import 'dart:async';
import 'base_component.dart';
import 'application_detail.dart';
import '../model/mdt_model.dart';
import '../model/errors.dart';
import '../service/mdt_query.dart';

@Component(
    selector: 'add_artifact',
    templateUrl: 'add_artifact.html',
    useShadowDom: false)
class AddArtifactComponent extends BaseComponent {
  MDTQueryService mdtQueryService;
  @NgOneWay('caller')
  ApplicationDetailComponent caller;
  @NgOneWay('app')
  MDTApplication app;

  //Form
  @NgTwoWay('htmlForm')
  dynamic htmlForm;
  String artifactName;
  String artifactVersion;
  String artifactSortIdentifier;
  String artifactBranch;
  String artifactTags;
  File artifactFile;
  bool lastVersion = false;
  void upfilesSelected(dynamic values) async {
    artifactFile = values.first;
  }

  AddArtifactComponent(this.mdtQueryService) {
    //_appId = routeProvider.parameters['appId'];
  }

  void addArtifact() async{
    errorMessage = null;
    if (checkParameter() == false){
      return;
    }
    try {
      isHttpLoading = true;
      MDTArtifact artifact = await mdtQueryService.addArtifact(app.apiKey,artifactFile,artifactName,latest:lastVersion,branch:artifactBranch,version:artifactVersion,sortIdentifier:artifactSortIdentifier, jsonTags:artifactTags);
      caller.loadAppVersions();

    } on ArtifactsError catch(e) {
      errorMessage = { 'type': 'danger', 'msg': e.toString()};
    } catch(e) {
      errorMessage = { 'type': 'danger', 'msg': 'Unknown error $e'};
    } finally {
      isHttpLoading = false;
    }


    /*MDTArtifact addArtifact(String apiKey, File file, String name,
      {bool latest,
      String branch,
      String version,
      String jsonTags,
      String sortIdentifier}) async {*/


  }

  bool checkParameter() {
    if (artifactName == null) {
      errorMessage = {
        'type': 'warning',
        'msg': 'Version name can not be null.'
      };
      return false;
    }
    if (artifactBranch == null) {
      errorMessage = {
        'type': 'warning',
        'msg': 'Developement Branch can not be null.'
      };
      return false;
    }
    if (artifactFile == null) {
      errorMessage = {
        'type': 'warning',
        'msg': 'Please select a file.'
      };
      return false;
    }
    if (lastVersion) {
      if (artifactVersion == null) {
        errorMessage = {'type': 'warning', 'msg': 'Version can not be null.'};
        return false;
      }
    }
    return true;
  }

}
/*
class ArtifactMsg {
  @ApiProperty(required: true)
  MediaMessage artifactFile;
  @ApiProperty(required: false)
  String sortIdentifier;
  @ApiProperty(required: false)
  String jsonTags;
}
Future<Response> addLastArtifactByAppKey(String apiKey, String artifactName, ArtifactMsg artifactsMsg) async{

}
  Future<Response> addArtifactByAppKey(String apiKey,String branch,String version, String artifactName, ArtifactMsg artifactsMsg) async{
}*/
