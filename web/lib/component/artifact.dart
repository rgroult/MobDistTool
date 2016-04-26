import 'package:angular/angular.dart';
import 'dart:core';
import 'base_component.dart';
import '../model/mdt_model.dart';
import 'add_artifact.dart';
import 'artifact_download_qrcode.dart';
import 'application_detail.dart';
import '../service/mdt_query.dart';

class MDTArtifactModule extends Module {
  MDTArtifactModule() {
    bind(ArtifactElementComponent);
    bind(AddArtifactComponent);
    bind(ArtifactDownloadQRCode);
  }
}

@Component(
    selector: 'artifact',
    templateUrl: 'artifact.html',
    useShadowDom: false
)
class ArtifactElementComponent extends BaseComponent  {
  MDTQueryService mdtQueryService;
  ApplicationDetailComponent _parent;
  @NgOneWay('sortIdentifier')
  String sortIdentifier ="";
 // @NgOneWay('displayVersion')
 // bool displayVersion = false;
  @NgOneWay('canDelete')
  bool canDelete = false;
  @NgOneWay('artifact')
  MDTArtifact artifact = new MDTArtifact({});
  bool isCollapsed = true;

  /*String artifactName = "";
  DateTime artifactCreationDate = new DateTime(0);*/


  List<String> get metaDataKeys => (artifact!=null && artifact.metaDataTags != null) ? artifact.metaDataTags.keys.toList() : new List<String>();

  int get artifactSize => artifact==null ? 0 : (artifact.size/(1024*1024)).round();

  bool get canInstall => ((scope.rootScope.context.currentDevice == Platform.IOS) || (scope.rootScope.context.currentDevice == Platform.ANDROID));

  void downloadArtifact(){
    mdtQueryService.downloadArtifact(artifact.uuid);
  }

  void installArtifact(){
    mdtQueryService.InstallArtifact(artifact.uuid);
  }

  void deleteArtifact(){
    _parent.deleteArtifact(artifact,sortIdentifier);
  }

  void generateQrCode(){
    var qrCodeTitle = artifact.name;
    if (artifact.branch == null){
      //latest
      qrCodeTitle = "$qrCodeTitle - Latest";
    }else {
      qrCodeTitle = "$qrCodeTitle - ${artifact.version} - ${artifact.branch}";
    }
    ArtifactDownloadQRCode.createQRCode(this._parent.modal,scope,qrCodeTitle,artifact.uuid);
  }

  ArtifactElementComponent(this.mdtQueryService,this._parent){
  }
}