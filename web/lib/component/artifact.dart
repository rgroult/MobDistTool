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

  void get canInstall => ((scope.rootScope.context.currentDevice == Platform.IOS) || (scope.rootScope.context.currentDevice == Platform.ANDROID));

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

/*var isMobile = {
    Android: function() {
        return navigator.userAgent.match(/Android/i);
    },
    BlackBerry: function() {
        return navigator.userAgent.match(/BlackBerry/i);
    },
    iOS: function() {
        return navigator.userAgent.match(/iPhone|iPad|iPod/i);
    },
    Opera: function() {
        return navigator.userAgent.match(/Opera Mini/i);
    },
    Windows: function() {
        return navigator.userAgent.match(/IEMobile/i);
    },
    any: function() {
        return (isMobile.Android() || isMobile.BlackBerry() || isMobile.iOS() || isMobile.Opera() || isMobile.Windows());
    }
};*/