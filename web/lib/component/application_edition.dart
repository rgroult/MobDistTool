import 'package:angular/angular.dart';
import 'base_component.dart';

@Component(
    selector: 'application_edition',
    templateUrl: 'application_edition.html',
    useShadowDom: false
)
class ApplicationEditionComponent extends BaseComponent {
  bool modeEdition  = false;
  bool isHttpLoading = false;
  bool isCollapsed = true;
  String message;
  String appName;
  String appPlatform;
  String appDescription;

}