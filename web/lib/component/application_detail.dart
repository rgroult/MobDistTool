import 'package:angular/angular.dart';
import 'base_component.dart';
import '../model/mdt_model.dart';
import '../model/errors.dart';
import '../service/mdt_query.dart';
import 'application_list.dart';
import 'confirmation_popover.dart';
import 'package:angular_ui/angular_ui.dart';

@Component(
    selector: 'application_detail',
    templateUrl: 'application_detail.html',
    useShadowDom: false
)
class ApplicationDetailComponent extends BaseComponent  {
  ApplicationListComponent _parent;
  MDTQueryService mdtQueryService;
  Modal modal;
  String _appId;
  //strange :unable to rename it to another name :S
  void get app => this;
  MDTApplication currentApp;
  bool hadUpdate = false;
  //artifact and sort
  Map<String,List<MDTArtifact>> groupedArtifacts = new Map<String,List<MDTArtifact>>();
  List<String> allSortedIdentifier = new List<String>();
  List<MDTArtifact>  applicationsArtifacts = new List<MDTArtifact>();
  //branches for filter
  List<MDTArtifact>  applicationsLastestVersion = new List<MDTArtifact>();
  List<String> allAvailableBranches = new List<String>();
  String currentBranchFilter = "";
  String currentSelectedBranch = "All";
  void selectFilter(String branch){
    if (branch == ""){
      currentBranchFilter = "";
      currentSelectedBranch = "All";
    }else {
      currentBranchFilter = branch;
      currentSelectedBranch = branch;
    }
  }

  void loadApp() async{
    errorMessage = null;
    try {
      isHttpLoading = true;
      MTDApplication app= await mdtQueryService.getApplication(_appId);
      currentApp = app;
      loadAppVersions();

    } on ApplicationError catch(e) {
      errorMessage = { 'type': 'danger', 'msg': e.toString()};
    } catch(e) {
      errorMessage = { 'type': 'danger', 'msg': 'Unknown error $e'};
    } finally {
      isHttpLoading = false;
    }
  }

  void loadAppVersions() async{
    errorMessage = null;
    try {
      isHttpLoading = true;
      applicationsArtifacts.clear();
      List<MDTArtifact> artifacts = await mdtQueryService.listArtifacts(currentApp.uuid,pageIndex:0,limitPerPage:50);
      if (artifacts.isNotEmpty){
        applicationsArtifacts.addAll(artifacts);
      }else {
        errorMessage = { 'type': 'warning', 'msg': 'No Artifact found'};
      }
    } on ArtifactsError catch(e) {
      errorMessage = { 'type': 'danger', 'msg': e.toString()};
    } catch(e) {
      errorMessage = { 'type': 'danger', 'msg': 'Unknown error $e'};
    } finally {
      isHttpLoading = false;
    }
    sortArtifacts();
  }

  //admin
  bool canAdmin(){
    bool displayAdminOption  = scope.rootScope.context.adminOptionsDisplayed;
    if (scope.rootScope.context.isUserAdmin && displayAdminOption){
      return true;
    }
    var email = scope.rootScope.context.currentUser["email"].toLowerCase();
    var adminFound =  currentApp.adminUsers.firstWhere((o) => (o.email.toLowerCase() == email), orElse: () => null);

    if (adminFound != null && displayAdminOption){
        return true;
    }
    /*
    bool isUserConnected = false;
  bool isUserAdmin = false;
  Map currentUser = null;
  bool adminOptionsDisplayed = false;
     */
    //var currentUser = mainComp().currentUser;
    return false;
  }

  void applicationEditionSucceed(MDTApplication updatedApp){
    currentApp = updatedApp;
    hadUpdate= true;
    loadAppVersions();
  }

  void addVersion(){
    modal.open(new ModalOptions(template:"<add_artifact app='currentApp' caller='app'></add_artifact>", backdrop: 'true'),scope);
  }

  void editApplication(){
    modal.open(new ModalOptions(template:"<application_edition modeEdition=true application='currentApp' caller='app''></application_edition>", backdrop: 'true'),scope);
  }
  void deleteApplication(){
    //show confirm popover
    //var modalInstance = modal.open(new ModalOptions(template:'<confirmation title="Delete application" text="Confirm delete application ${app.name}"></confirmation>', backdrop: false), scope);
    var modalInstance = ConfirmationComponent.createConfirmation(modal,scope,"Are you sure to delete ${currentApp.name} ?","All versions will be trash. This can't be undone.");
    modalInstance.result
      ..then((v) {
      print('result $v');
    });
  }

  ApplicationDetailComponent(RouteProvider routeProvider,this._parent,this.modal,this.mdtQueryService){
    print("ApplicationDetailComponent created");
    _appId = routeProvider.parameters['appId'];
    currentApp = _parent.finByUUID(_appId);
    loadApp();

    RouteHandle route = routeProvider.route.newHandle();
    route.onLeave.listen((RouteEvent event) {
      _parent.isApplicationSelected = false;
      if (hadUpdate){
        _parent.applicationListNeedBeReloaded();
      }
    });
    /*
    route.onEnter.listen((RouteEvent e){
      print("Do something when the route is activated.");
      scope.rootScope.context.enterRoute("Versions",e.path,3);
    });*/

  }

  String versionForSortIdentifier(String sortIdentifier){
    var artifact = groupedArtifacts[sortIdentifier].first;
    if (artifact == null) {
      return "Unknown version - No Branch";
    }
    return "${artifact.version} - ${artifact.branch}";
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

  void loadArtifacts() {
    var artifact = new MDTArtifact({
      "uuid" : "dsdsdd",
      "branch" : "master",
      "name" : "prod",
      "creationDate" : new DateTime(2015),
      "version" : "X.Y.Z",
      "size" : 20481024,
      "sortIdentifier" : "X.Y.Z"
    });
    var artifact1 = new MDTArtifact({
      "uuid" : "dsdsdd",
      "branch" : "develop",
      "name" : "prod",
      "creationDate" : new DateTime(2015),
      "version" : "X.Y.Z",
      "size" : 10241356,
      "sortIdentifier" : "X.Y.Z"
    });
    var artifact2 = new MDTArtifact({
      "uuid" : "dsdsdd",
      "branch" : "master",
      "name" : "dev",
      "creationDate" : new DateTime(2015),
      "version" : "X.Y.Z",
      "size" : 10241024,
      "sortIdentifier" : "X.Y.Z"
    });
    var artifact3 = new MDTArtifact({
      "uuid" : "dsdsdd",
      "branch" : "develop",
      "name" : "dev",
      "creationDate" : new DateTime(2015),
      "version" : "X.Y.ZZ",
      "sortIdentifier" : "X.Y.ZZ"
    });
    var artifact4 = new MDTArtifact({
      "uuid" : "dsdsdd",
      "branch" : "develop",
      "name" : "prod",
      "creationDate" : new DateTime(2015),
      "version" : "X.Y.ZZ",
      "sortIdentifier" : "X.Y.ZZ"
    });
    //applicationsArtifacts = new List<MDTArtifact>();
    applicationsArtifacts.add(artifact);
    applicationsArtifacts.add(artifact1);
    applicationsArtifacts.add(artifact2);
    applicationsArtifacts.add(artifact3);
    applicationsArtifacts.add(artifact4);
   // applicationsLastestVersion = new List<MDTArtifact>();
    applicationsLastestVersion.add(artifact);
    applicationsLastestVersion.add(artifact2);
  }
}