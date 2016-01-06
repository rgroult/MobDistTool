import 'package:angular/angular.dart';
import 'dart:core';
import 'base_component.dart';
import '../model/mdt_model.dart';

class MDTArtifactModule extends Module {
  MDTArtifactModule() {
    bind(ArtifactElementComponent);
  }
}

@Component(
    selector: 'artifact',
    templateUrl: 'artifact.html',
    useShadowDom: false
)
class ArtifactElementComponent extends BaseComponent  {
  @NgOneWay('displayVersion')
  Bool displayVersion;
  @NgOneWay('artifact')
  MDTArtifact artifact;
  int artifactSize(){
    return (artifact.size/(1024*1024)).round();
  }
  ArtifactElementComponent(){

  }
}