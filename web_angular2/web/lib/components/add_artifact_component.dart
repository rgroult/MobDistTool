import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';
import 'dart:async';
import 'dart:html';
import '../services/modal_service.dart';
import '../commons.dart';

abstract class AddArtifactComponentAware {
  void updateNeeded();
}

@Component(
    selector: 'add_artifact',
    directives: const [ErrorComponent,materialDirectives],
    providers: materialProviders,
    templateUrl: 'add_artifact_component.html')
class AddArtifactComponent extends BaseComponent {
  MDTQueryService _mdtQueryService;
  AddArtifactComponentAware delegate;
  MDTApplication app;
  String artifactName = "";
  String artifactVersion = "";
  String artifactSortIdentifier;
  String artifactBranch = "";
  String artifactTags;
  File artifactFile;
  String artifactFilename = "";
  bool lastVersion = false;

  AddArtifactComponent(this._mdtQueryService) {
  }

  @Input()
  void set parameters(Map<String,dynamic> params) {
    app = params["application"];
    delegate = params["delegate"];
    artifactName = "";
    artifactVersion = "";
    artifactSortIdentifier = null;
    artifactBranch = "";
    artifactTags = null;
    artifactFile = null;
    artifactFilename = "";
    lastVersion = false;
  }

  Future onInputChange(dynamic event) {
    var file = event.currentTarget.files.first;
    artifactFile = file;
    artifactFilename = file.name;
  }

  Future addArtifact() async{
    error = null;
    if (isHttpLoading){
      return;
    }
    if (checkParameter() == false){
      return;
    }
    try {
      isHttpLoading = true;
      MDTArtifact artifact = await _mdtQueryService.addArtifact(app.apiKey,artifactFile,artifactName,latest:lastVersion,branch:artifactBranch,version:artifactVersion,sortIdentifier:artifactSortIdentifier, jsonTags:artifactTags);
      if (artifact != null){
        delegate?.updateNeeded();
        error = new UIError(' Version ${artifact.name} uploaded successfully!',"",ErrorType.SUCCESS);
      }else {
        error = new UIError('/!\ Unknown error',"",ErrorType.ERROR);
      }
    } on ArtifactsError catch(e) {
      error = new UIError(ArtifactsError.errorCode,e.message,ErrorType.ERROR);
    } catch(e) {
      error = new UIError("Unknown Error","$e",ErrorType.ERROR);
    } finally {
      isHttpLoading = false;
    }
  }

  bool checkParameter() {
    if (artifactName.isEmpty) {
      error = new UIError('Version name can not be null.',"",ErrorType.WARNING);
      return false;
    }

    if (artifactFile == null) {
      error = new UIError('Please select a file.',"",ErrorType.WARNING);
      return false;
    }
    if (!lastVersion) {
      if (artifactBranch.isEmpty) {
        error = new UIError('Developement Branch can not be null.',"",ErrorType.WARNING);
        return false;
      }
      if (artifactVersion.isEmpty) {
        error = new UIError('Version can not be null.',"",ErrorType.WARNING);
        return false;
      }
    }
    return true;
  }

}