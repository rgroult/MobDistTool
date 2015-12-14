import 'package:angular/angular.dart';
import 'package:angular_ui/angular_ui.dart';
import 'dart:convert';
import 'dart:html';
//import 'dart:io' show Platform;
import 'BaseComponents.dart';

@Component(
    selector: 'apps_list',
    templateUrl: 'apps_list.html',
    publishAs: 'AppsCtrl'
)
class ApplicationsComponent extends BaseComponent {
    var allApps = new List<MDTApplication>();
    ApplicationsComponent(){
        loadAppList();
    }

    void loadAppList(){
      var app1 = new MDTApplication();
      app1.uuid = "dsfsdfsdfsdf";
      app1.apiKey = "aîkey12345";
      app1.description = "test App1";
      app1.name = "appName1";
      app1.platform = "IOS";
      allApps.add(app1);

      var app2 = new MDTApplication();
      app2.uuid = "ssdfsds£%%%£dsd";
      app2.apiKey = "aîkdsfsdfey12345";
      app2.description = "test App2";
      app2.name = "appName2";
      app2.platform = "Android";
      allApps.add(app2);
    }

  /*  void loadAppList() async {
        String url = "${scope.rootScope.context.mdtServerApiRootUrl}/applications/v1/search";
        if (Platform.isAndroid){
            url+="?platform=android";
        }else if (Platform.isMacOS){
            url+="?platform=ios";
        }
    }*/
}
/*
@Component(
    selector: 'app_comp',
    template: 'app.html')
class AppComponent {

}*/