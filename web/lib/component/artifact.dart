import 'package:angular/angular.dart';
import 'dart:core';
import 'base_component.dart';
import '../model/mdt_model.dart';
import 'add_artifact.dart';

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
  @NgOneWay('displayVersion')
  bool displayVersion;
  @NgOneWay('canDelete')
  bool canDelete;
  @NgOneWay('artifact')
  MDTArtifact artifact;
  int artifactSize(){
    return (artifact.size/(1024*1024)).round();
  }
  ArtifactElementComponent(){

  }
}