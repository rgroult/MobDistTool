import 'dart:async';
import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import '../commons.dart';
import '../components/edit_application_component.dart';

@Component(
    selector: 'application_list',
    templateUrl: 'application_list_component.html',
    directives: const [materialDirectives],
    providers: materialProviders,
)
class ApplicationListComponent extends BaseComponent implements OnInit,EditAppComponentAware{
    ModalService _modalService;
    final allPlatformsFilters = ['All','iOS','Android'];
    var currentPlatformFilter = '';
    var currentSelectedPlatform = 'All';
    List<String> applicationFavorites = new List<String>();
    var isFavoritesExpanded = false;
    var isOthersAppExpanded = false;

    ApplicationListComponent(GlobalService globalService,this._modalService) : super.withGlobal(globalService);
    List<MDTApplication> allFilteredApplications = [];
    List<MDTApplication> favoritesFilteredApplications = [];

    Future ngOnInit() async {
      await refreshApplications();
      isFavoritesExpanded = favoritesFilteredApplications.isNotEmpty;
      isOthersAppExpanded = !isFavoritesExpanded;
    }

    void selectApplication(String appUUID){
      global_service.goToApplication(appUUID);
    }

    void manageLoadAppResult(dynamic errorOccured){
      if (errorOccured == null){
        return;
      }
    }

    void updateNeeded(){
      refreshApplications(forceRefresh:true);
    }

    void forceRefresh(){
      refreshApplications(forceRefresh: true);
    }

    Future refreshApplications({bool forceRefresh: false}) async{
      var errorOccured = await global_service.loadAppsIfNeeded(forceRefresh:forceRefresh);
      manageLoadAppResult(errorOccured);
      filterApplications();
    }

    void filterApplications(){
       var apps = global_service.allApps;
       applicationFavorites = global_service.connectedUser.favoritesApplicationsUUID;
        allFilteredApplications.clear();
        favoritesFilteredApplications.clear();
        String currentFilter = currentPlatformFilter.toLowerCase();
        for (MDTApplication app in apps){
            if (currentPlatformFilter.length>0 && app.platform.matchAsPrefix(currentFilter) == null){
                continue;
            }
            allFilteredApplications.add(app);
            //favoritesFilteredApplications.add(app);
            if (isFavorite(app)){
                favoritesFilteredApplications.add(app);
            }
        }
    }

    void selectFilter(String platform){
      if (platform == "All"){
        currentPlatformFilter = "";
      }else {
        currentPlatformFilter = platform;
      }
      currentSelectedPlatform = platform;
      filterApplications();
    }

    bool isFavorite(MDTApplication app){
      return applicationFavorites.contains(app.uuid);
    }

    void createApplication(){
      _modalService.displayCreateApplication(this);
    }
}


class ApplicationListComponent1 extends BaseComponent  {
  var allApps = new List<MDTApplication>();
  var isApplicationSelected = false;
  final allPlatforms = ['iOS','Android'];
  var currentPlatformFilter = '';
  var currentSelectedPlatform = 'All';
  List<String> applicationFavorites = new List<String>();
  //NgRoutingHelper locationService;
  MDTQueryService mdtQueryService;
  var errorMessage;
  //Modal modal;
  var isViewAsList = false;
  void setListMode(bool viewAsList){
    isViewAsList = viewAsList;
  }
  bool isFavoritesOpened = true;
  bool isAllAppsOpened = false;

  /*
  void set scope(Scope scope){
    super.scope = scope;
    MDTUser currentUser = scope.rootScope.context.currentUser;
    if (currentUser.favoritesApplicationsUUID != null){
      applicationFavorites.addAll(currentUser.favoritesApplicationsUUID);
      if (applicationFavorites.length > 0){
        isFavoritesOpened = true;
        isAllAppsOpened = false;
      }else{
        isFavoritesOpened = false;
        isAllAppsOpened = true;
      }
    }
  }*/

  //strange :unable to rename it to another name :S
  ApplicationListComponent1 get app => this;

  ApplicationListComponent1(/*this.locationService,/*RouteProvider routeProvider,*/this.modal,*/this.mdtQueryService){
    print ("ApplicationsComponent created");
    loadApps();
  }

  bool isFavorite(MDTApplication app){
    return global_service.isFavorite(app.uuid);
  }

  void selectFilter(String platform){
    if (platform == ""){
      currentPlatformFilter = "";
      currentSelectedPlatform = "All";
    }else {
      currentPlatformFilter = platform;
      currentSelectedPlatform = platform;
    }
  }

  void applicationEditionSucceed(MDTApplication appCreated){
    applicationListNeedBeReloaded();
  }
/*
  void displayApplicationCreationPopup(){
     modal.open(new ModalOptions(template:"<application_edition modeEdition='false' caller='app' ></application_edition>", backdrop: 'true'),scope);
  }

  void hideCurrentPopup(){
    modal.hide();
  }

  void showApplications(RouteEvent e) {
    isApplicationSelected = false;
  }
*/
  MDTApplication finByUUID(String appUUID){
    var app =  allApps.firstWhere((MDTApplication a) => a.uuid == appUUID);
    return app;
    //return apps.first;
  }

  bool canAdminApp(MDTApplication app){
    return (app == allApps[0]);
  }
/*
  void appSelected(String appUUID){
    locationService.router.go('apps.artifacts', {'appId': appUUID});
    isApplicationSelected = true;
  }
*/
  void applicationListNeedBeReloaded(){
    loadApps();
  }

  Future loadApps() async{
    errorMessage = null;
    try {
      isHttpLoading = true;
      allApps.clear();
      var apps= await mdtQueryService.getApplications();
      if (apps.isNotEmpty){
        allApps.addAll(apps);
      }else {
        errorMessage = { 'type': 'warning', 'msg': 'No Application found'};
      }
    } on ApplicationError catch(e) {
      errorMessage = { 'type': 'danger', 'msg': e.toString()};
    } catch(e) {
      errorMessage = { 'type': 'danger', 'msg': 'Unknown error $e'};
    } finally {
      isHttpLoading = false;
    }
  }
}