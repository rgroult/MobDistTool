import 'dart:async';
import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:angular2/router.dart';
import '../commons.dart';

@Component(
    selector: 'application_detail',
    templateUrl: 'application_detail_component.html',
    directives: const [materialDirectives],
    providers: materialProviders,
    )
class ApplicationDetailComponent extends BaseComponent implements OnInit{
  final RouteParams _routeParams;
  MDTQueryService _mdtQueryService;
  MDTApplication currentApp;

  //versions sorted
  Map<String,List<MDTArtifact>> groupedArtifacts = new Map<String,List<MDTArtifact>>();
  List<String> allSortedIdentifier = new List<String>();
  List<MDTArtifact>  applicationsArtifacts = new List<MDTArtifact>();
  List<MDTArtifact>  applicationsLastestVersion = new List<MDTArtifact>();

  //branhes
  List<String> allAvailableBranches = new List<String>();

  //edition
  bool isAdminUsersCollapsed = true;
  bool isMaxVersionEnabledCollapsed = true;
  bool get maxVersionEnabled => (currentApp != null && currentApp.maxVersionSecretKey != null);
  String administratorToAdd;

  ApplicationDetailComponent(this._routeParams,this._mdtQueryService, GlobalService globalService) : super.withGlobal(globalService);

  Future<Null> ngOnInit() async {
    var _uuid = _routeParams.get('appid');
    currentApp = global_service.allApps.firstWhere((app) => app.uuid == _uuid);
    print("Selected App $currentApp");
    if (currentApp!=null){
      loadApp();
    }
    //refreshApplications();
  }

  Future loadApp() async{
    error = null;
    try {
      isHttpLoading = true;
      var app= await _mdtQueryService.getApplication(currentApp.uuid);
      currentApp = app;
      await loadAppVersions();

    } on ApplicationError catch(e) {
      error = new UIError(LoginError.errorCode,e.message,ErrorType.ERROR);
    } catch(e) {
      error = new UIError("UNKNOWN ERROR","Unknown error $e",ErrorType.ERROR);
    } finally {
      isHttpLoading = false;
    }
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
      error = new UIError(LoginError.errorCode,e.message,ErrorType.ERROR);
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
    // allAvailableBranches.insert(0, "_All");
  }

  //admin
  bool canAdmin(){
    bool displayAdminOption  =  global_service.adminOptionsDisplayed;
    if (global_service.connectedUser.isSystemAdmin && displayAdminOption){
      return true;
    }
    var email = global_service.connectedUser.email.toLowerCase();
    var adminFound =  currentApp.adminUsers.firstWhere((o) => o.email!=null ? (o.email.toLowerCase() == email) : false, orElse: () => null);

    if (adminFound != null && displayAdminOption){
      return true;
    }
    return false;
  }
}