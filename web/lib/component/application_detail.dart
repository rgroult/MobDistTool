import 'package:angular/angular.dart';
import 'base_component.dart';
import '../model/mdt_model.dart';
import 'application_list.dart';

@Component(
    selector: 'application_detail',
    templateUrl: 'application_detail.html',
    useShadowDom: false
)
class ApplicationDetailComponent extends BaseComponent  {
  ApplicationListComponent _parent;
  String _appId;
  MDTApplication app;
  ApplicationDetailComponent(RouteProvider routeProvider,this._parent){
    _appId = routeProvider.parameters['appId'];
    app = _parent.allApps.first;
  }
}