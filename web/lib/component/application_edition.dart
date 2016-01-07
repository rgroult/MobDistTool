import 'package:angular/angular.dart';
import 'dart:async';
import 'base_component.dart';
import 'application_list.dart';
import '../service/mdt_query.dart';

@Component(
    selector: 'application_edition',
    templateUrl: 'application_edition.html',
    useShadowDom: false
)
class ApplicationEditionComponent extends BaseComponent {
  ApplicationListComponent _parent;
  MDTQueryService mdtQueryService;
  bool modeEdition  = false;
  bool isHttpLoading = false;
  bool isCollapsed = true;
  var message = null;//{ 'type': 'danger', 'msg': 'Oh snap! Change a few things up and try submitting again.' };
  String appName;
  String appPlatform;
  String appDescription;

  void hideMessage(){
    message = null;
  }

  bool checkParameter(){
    if (appName == null){
      message = { 'type': 'warning', 'msg': 'Application name can not be null.' };
      return false;
    }
    if (appDescription == null){
      message = { 'type': 'warning', 'msg': 'Application description can not be null.' };
      return false;
    }
    if (appPlatform == null){
      message = { 'type': 'warning', 'msg': 'Please select a platform.' };
      return false;
    }
    return true;
  }

  void createApp() async{
    message = null;
    if (isHttpLoading){
      return;
    }
    isHttpLoading = true;

    if (checkParameter() == false){
      return;
    }
    isHttpLoading = true;
    var response = await mdtQueryService.createApplication(appName,appDescription,appPlatform,"");
  }

  ApplicationEditionComponent(RouteProvider routeProvide,this._parent,this.mdtQueryService){
    //super(mdtQueryService); MDTQueryService mdtQueryService,
  }
}