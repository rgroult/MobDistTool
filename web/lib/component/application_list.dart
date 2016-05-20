import 'dart:async';
import 'package:angular/angular.dart';
import 'base_component.dart';
import 'package:angular_ui/angular_ui.dart';
import '../model/mdt_model.dart';
import '../service/mdt_query.dart';
import '../model/errors.dart';

@Component(
    selector: 'application_list',
    templateUrl: 'application_list.html',
    useShadowDom: false
)
class ApplicationListComponent extends BaseComponent  {
  var allApps = new List<MDTApplication>();
  var isApplicationSelected = false;
  final allPlatforms = ['iOS','Android'];
  var currentPlatformFilter = '';
  var currentSelectedPlatform = 'All';
  List<String> applicationFavorites = new List<String>();
  NgRoutingHelper locationService;
  MDTQueryService mdtQueryService;
  Modal modal;
  var isViewAsList = false;
  void setListMode(bool viewAsList){
    isViewAsList = viewAsList;
  }
  bool isFavoritesOpened = true;
  bool isAllAppsOpened = false;

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
  }

  //strange :unable to rename it to another name :S
  ApplicationListComponent get app => this;

  ApplicationListComponent(this.locationService,/*RouteProvider routeProvider,*/this.modal,this.mdtQueryService){
    print ("ApplicationsComponent created");
    loadApps();
  }

  bool isFavorite(MDTApplication app){
    return applicationFavorites.contains(app.uuid);
  }

  void addToFavorite(MDTApplication app){
    if (!isFavorite(app)){
      applicationFavorites.add(app.uuid);
      updateUsersAppFavorites();
    }
  }

  void removeToFavorite(MDTApplication app){
    if (isFavorite(app)){
      applicationFavorites.remove(app.uuid);
      updateUsersAppFavorites();
    }
  }

  void updateUsersAppFavorites(){
    MDTUser currentUser = scope.rootScope.context.currentUser;
    currentUser.favoritesApplicationsUUID.clear();
    currentUser.favoritesApplicationsUUID.addAll(applicationFavorites);
    mdtQueryService.updateUser(currentUser.email,favoritesApps: applicationFavorites);
  }

  String iconForApp(MDTApplication app){
    /*if (app.appIcon.length>0){
      return app.appIcon;
    }*/
    return "js/holder.min.js?theme=gray";
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

  void displayApplicationCreationPopup(){
     modal.open(new ModalOptions(template:"<application_edition modeEdition='false' caller='app' ></application_edition>", backdrop: 'true'),scope);
  }

  void hideCurrentPopup(){
    modal.hide();
  }

  void showApplications(RouteEvent e) {
    isApplicationSelected = false;
  }

  MDTApplication finByUUID(String appUUID){
    var app =  allApps.firstWhere((MDTApplication a) => a.uuid == appUUID);
    return app;
    //return apps.first;
  }

  bool canAdminApp(MDTApplication app){
    return (app == allApps[0]);
  }

  void appSelected(String appUUID){
    locationService.router.go('apps.artifacts', {'appId': appUUID});
    isApplicationSelected = true;
  }

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