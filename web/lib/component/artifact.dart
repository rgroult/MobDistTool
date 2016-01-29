import 'package:angular/angular.dart';
import 'dart:core';
import 'base_component.dart';
import '../model/mdt_model.dart';
import 'add_artifact.dart';
import '../service/mdt_query.dart';

class MDTArtifactModule extends Module {
  MDTArtifactModule() {
    bind(ArtifactElementComponent);
    bind(AddArtifactComponent);
  }
}

@Component(
    selector: 'artifact',
    templateUrl: 'artifact.html',
    useShadowDom: false
)
class ArtifactElementComponent extends BaseComponent  {
  MDTQueryService mdtQueryService;
  @NgOneWay('displayVersion')
  bool displayVersion;
  @NgOneWay('canDelete')
  bool canDelete;
  @NgOneWay('artifact')
  MDTArtifact artifact;
  int artifactSize(){
    return (artifact.size/(1024*1024)).round();
  }

  bool get canInstall => ((scope.rootScope.context.currentDevice == Platform.IOS) || (scope.rootScope.context.currentDevice == Platform.ANDROID));

  void downloadArtifact(){
    mdtQueryService.downloadArtifact(artifact.uuid);
  }

  void installArtifact(){
    mdtQueryService.InstallArtifact(artifact.uuid);
  }

  void deleteArtifact(){

  }

  ArtifactElementComponent(this.mdtQueryService){

  }
}