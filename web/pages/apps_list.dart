import 'package:angular/angular.dart';
import 'dart:io' show Platform;
import 'BaseComponents.dart';

@Component(
    selector: 'apps_list',
    templateUrl: 'apps_list.html')
class ApplicationsComponent extend BaseComponents {
    ApplicationsComponent(){
        loadAppList();
    }

    void loadAppList() async {
        String url = "${scope.rootScope.context.mdtServerApiRootUrl}/applications/v1/search";
        if (Platform.isAndroid){
            url+="?platform=android";
        }else if (Platform.isMacOS){
            url+="?platform=ios";
        }
    }
}

@Component(
    selector: 'app_comp',
    template: 'apps_list.html')
class AppComponent {

}