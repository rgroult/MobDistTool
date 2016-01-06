import 'package:angular/angular.dart';
import 'base_component.dart';
import 'package:angular_ui/angular_ui.dart';
import '../model/mdt_model.dart';

@Component(
    selector: 'application_list',
    templateUrl: 'application_list.html',
    useShadowDom: false
)
class ApplicationListComponent extends BaseComponent  {
  var allApps = new List<MDTApplication>();
  var isApplicationSelected = false;
  NgRoutingHelper locationService;
  Modal modal;
  ApplicationListComponent(this.locationService,RouteProvider routeProvider,this.modal){
    print ("ApplicationsComponent created");
    loadAppList();
  }

  void displayApplicationCreationPopup(){
     modal.open(new ModalOptions(template:"<application_edition modeEdition=false></application_edition>", backdrop: true),scope);
  }

  void displayApplicationEditionPopup(){
     modal.open(new ModalOptions(template:"<application_edition modeEdition=true></application_edition>", backdrop: true),scope);
  }

  void hideCurrentPopup(){
    modal.hide();
  }

  void showApplications(RouteEvent e) {
    isApplicationSelected = false;
  }

  Boolean canAdminApp(MDTApplication app){
    return (app == allApps[0]);
  }

  void appSelected(String appUUID){
    locationService.router.go('apps.artifacts', {'appId': appUUID});
    isApplicationSelected = true;
  }

  void loadAppList(){
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