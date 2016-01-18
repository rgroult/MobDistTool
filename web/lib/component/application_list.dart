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
  NgRoutingHelper locationService;
  MDTQueryService mdtQueryService;
  Modal modal;
  //strange :unable to rename it to another name :S
  void get app => this;
/*
  void set scope(Scope _scope){
    super.scope= _scope;
    scope.rootScope.context.enterRoute("Applications","/apps",1);
  }
*/
  ApplicationListComponent(this.locationService,/*RouteProvider routeProvider,*/this.modal,this.mdtQueryService){
    print ("ApplicationsComponent created");
    loadApps();
    //loadAppListFake();
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

  Boolean canAdminApp(MDTApplication app){
    return (app == allApps[0]);
  }

  void appSelected(String appUUID){
    locationService.router.go('apps.artifacts', {'appId': appUUID});
    isApplicationSelected = true;
  }

  void applicationListNeedBeReloaded(){
    loadApps();
  }

  void loadApps() async{
    errorMessage = null;
    try {
      isHttpLoading = true;
      allApps.clear();
      List<MTDApplication> apps= await mdtQueryService.getApplications();
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

  void loadAppListFake(){
    var app1Data = {
    "uuid" : "dsfsdfsdfsdf",
    "apiKey" : "aîkey12345",
    "description" : "test App1",
    "name" : "long long long appName1 very long long",
    "platform" : "IOS"
    };
    var app2Data = {
      "uuid" : "234232",
      "apiKey" : "aîkeyapp2",
      "description" : "test App2 with long description and very long description",
      "name" : "appName2",
      "platform" : "Android"
    };


    var app1 = new MDTApplication(app1Data);
    allApps.add(app1);

    var app2 = new MDTApplication(app2Data);
    allApps.add(app2);

    allApps.add(app1);
    allApps.add(app2);
    allApps.add(app1);

    allApps.add(app2);
  }
}