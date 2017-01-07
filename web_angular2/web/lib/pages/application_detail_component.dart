import 'dart:async';
import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:angular2/router.dart';
import '../components/application_detail_header_component.dart';
import '../commons.dart';
import '../components/artifact_component.dart';
import '../components/artifact_download_qrcode_component.dart';
import '../components/add_artifact_component.dart';
import '../services/modal_service.dart';

@Component(
    selector: 'application_detail',
    templateUrl: 'application_detail_component.html',
    directives: const [materialDirectives,ApplicationDetailHeaderComponent,ErrorComponent,ArtifactComponent,ArtifactDownloadQRCodeComponent],
    providers: materialProviders,
    )
class ApplicationDetailComponent extends BaseComponent implements OnInit,AddArtifactComponentAware{
  final RouteParams _routeParams;
  MDTQueryService _mdtQueryService;
  ModalService _modalService;
  MDTApplication currentApp;

  //versions sorted
  Map<String,List<MDTArtifact>> groupedArtifacts = new Map<String,List<MDTArtifact>>();
  List<String> allSortedIdentifier = new List<String>();
  List<String> filteredSortedIdentifier = new List<String>();
  List<MDTArtifact>  applicationsArtifacts = new List<MDTArtifact>();
  List<MDTArtifact>  applicationsLastestVersion = new List<MDTArtifact>();

  //branches
  List<String> allAvailableBranches = new List<String>();
  String currentBranchFilter = "";
  String currentSelectedBranch = "All";

  //edition
  bool isAdminUsersCollapsed = true;
  bool isMaxVersionEnabledCollapsed = true;
  bool get maxVersionEnabled => (currentApp != null && currentApp.maxVersionSecretKey != null);
  String administratorToAdd;
  bool get canAdmin => canAdministrate(currentApp);

  ApplicationDetailComponent(this._routeParams,this._mdtQueryService,this._modalService, GlobalService globalService) : super.withGlobal(globalService);

  Future<Null> ngOnInit() async {
    var _uuid = _routeParams.get('appid') ?? "";
    currentApp = global_service.allApps?.firstWhere((app) => app.uuid == _uuid);
    print("Selected App $currentApp");
    if (currentApp!=null){
      loadAppVersions();
    }
    //refreshApplications();
  }

  void updateNeeded(){
    loadAppVersions();
  }

  void appUpdated(MDTApplication app){
    currentApp = app;
  }

  void selectFilter(String branch){
    if (branch == ""){
      currentBranchFilter = "";
      currentSelectedBranch = "All";
    }else {
      currentBranchFilter = branch;
      currentSelectedBranch = branch;
    }
    filterIdentifier();
  }

  void filterIdentifier(){
    filteredSortedIdentifier.clear();
    filteredSortedIdentifier.addAll(allSortedIdentifier.where((identifier) => identifier.endsWith(currentBranchFilter)).toList()
        ..sort((a, b) => b.compareTo(a)));
  }

  Future loadAppVersions() async{
    error = null;
    try {
      isHttpLoading = true;
      applicationsArtifacts.clear();
      applicationsLastestVersion.clear();
      List<MDTArtifact> artifacts = await _mdtQueryService.listArtifacts(currentApp.uuid,pageIndex:0,limitPerPage:50);
      if (artifacts.isNotEmpty){
        applicationsArtifacts.addAll(artifacts);
      }else {
        //errorMessage = { 'type': 'warning', 'msg': 'No Artifact found'};
      }
      List<MDTArtifact> latestArtifacts = await _mdtQueryService.listLatestArtifacts(currentApp.uuid);
      if (latestArtifacts.isNotEmpty){
        applicationsLastestVersion=latestArtifacts;
      }
    } on ArtifactsError catch(e) {
      error = new UIError(ArtifactsError.errorCode,e.message,ErrorType.ERROR);
    } catch(e) {
      error = new UIError("UNKNOWN ERROR","Unknown error $e",ErrorType.ERROR);
    } finally {
      isHttpLoading = false;
    }
    sortArtifacts();
  }

  void sortArtifacts() {
    groupedArtifacts.clear();
    allSortedIdentifier.clear();
    allAvailableBranches.clear();
    //grouped artifacts
    for (var artifact in applicationsArtifacts) {
      String key = "${artifact.sortIdentifier} - ${artifact.branch}";
      if(groupedArtifacts[key] == null){
        groupedArtifacts[key] = new List<MDTArtifact>();
        allSortedIdentifier.add(key);
        allAvailableBranches.add(artifact.branch);
      }
      groupedArtifacts[key].add(artifact);
    }
    allAvailableBranches = allAvailableBranches.toSet().toList()..sort();
    filterIdentifier();
    // allAvailableBranches.insert(0, "_All");
  }
/*
  String versionForSortIdentifier(String sortIdentifier){
    try {
      var artifact = groupedArtifacts[sortIdentifier].first;
      return "${artifact.version} - ${artifact.branch}";
    }catch(e){
      return "Unknown version - No Branch";
    }
  }*/

  String versionForSortIdentifier(String sortIdentifier){
    try {
      var artifact = groupedArtifacts[sortIdentifier].first;
      return artifact.version;
    }catch(e){
      return "Unknown version";
    }
  }

  String branchForSortIdentifier(String sortIdentifier){
    try {
      var artifact = groupedArtifacts[sortIdentifier].first;
      return artifact.branch;
    }catch(e){
      return "No Branch";
    }
  }

  void displayAddArtifactModal(){
    _modalService.displayAddArtifact(currentApp,this);
  }

  void artifactDeleted(ArtifactDeletedEvent deletedEvent){
    deleteArtifact(deletedEvent.artifact,deletedEvent.sortIdentifier);

  }

  Future deleteArtifact(MDTArtifact artifact, String fromSortIdentifier) async{
    var result = await _mdtQueryService.deleteArtifact(artifact.uuid);
    if (result == true){
      if (fromSortIdentifier != null && fromSortIdentifier.isNotEmpty){
        var isremoved = groupedArtifacts[fromSortIdentifier].remove(artifact);
        if (isremoved && groupedArtifacts[fromSortIdentifier].isEmpty){
          allSortedIdentifier.remove(fromSortIdentifier);
          groupedArtifacts.remove(fromSortIdentifier);
        }
      }else{
        applicationsLastestVersion.remove(artifact);
      }
    }else {
      error = new UIError('Unable to delete version',"",ErrorType.ERROR);
    }
  }
}