import 'package:angular/angular.dart';
import 'dart:async';
import 'base_component.dart';
import 'application_list.dart';
import '../service/mdt_query.dart';
import '../model/errors.dart';
import '../model/mdt_model.dart';

@Component(
    selector: 'application_edition',
    templateUrl: 'application_edition.html',
    useShadowDom: false
)
class ApplicationEditionComponent extends BaseComponent {
  ApplicationListComponent _parent;
  MDTQueryService mdtQueryService;
  @NgOneWay('modeEdition')
  bool modeEdition = true;
  bool isHttpLoading = false;
  @NgOneWay('application')
  //MDTApplication application;
  void set application(MDTApplication app){
    appName = app.name;
    appPlatform = app.platform;
    appDescription = app.description;
    appUUID = app.uuid;
  }
  String appName;
  String appPlatform;
  String appDescription;
  String appUUID;

  void hideMessage(){
    errorMessage = null;
  }

  bool checkParameter(){
    if (appName == null){
      errorMessage = { 'type': 'warning', 'msg': 'Application name can not be null.' };
      return false;
    }
    if (appDescription == null){
      errorMessage = { 'type': 'warning', 'msg': 'Application description can not be null.' };
      return false;
    }
    if (appPlatform == null){
      errorMessage = { 'type': 'warning', 'msg': 'Please select a platform.' };
      return false;
    }
    return true;
  }

  void updateApp() async{
    errorMessage = null;
    if (isHttpLoading){
      return;
    }

    if (checkParameter() == false){
      return;
    }
    try {
      isHttpLoading = true;
      MDTApplication appUpdated = await mdtQueryService.updateApplication(appUUID, appName,appDescription,"");
      if (appCreated !=null){
        _parent.applicationListNeedBeReloaded();
        errorMessage = { 'type': 'sucess', 'msg': ' Application ${appCreated.name} updated successfully!'};
      }else {
        errorMessage = { 'type': 'danger', 'msg': ' /!\ Unknown error'};
      }
    } on ApplicationError catch(e) {
      errorMessage = { 'type': 'danger', 'msg': e.toString()};
    } catch(e) {
      errorMessage = { 'type': 'danger', 'msg': 'Unknown error $e'};
    } finally {
      isHttpLoading = false;
    }

  }

  void createApp() async{
    errorMessage = null;
    if (isHttpLoading){
      return;
    }

    if (checkParameter() == false){
      return;
    }
    try {
      isHttpLoading = true;
      MDTApplication appCreated = await mdtQueryService.createApplication(appName,appDescription,appPlatform,"");
      if (appCreated !=null){
        _parent.applicationListNeedBeReloaded();
        errorMessage = { 'type': 'sucess', 'msg': ' Application ${appCreated.name} created successfully!'};
      }else {
        errorMessage = { 'type': 'danger', 'msg': ' /!\ Unknown error'};
      }
    } on ApplicationError catch(e) {
      errorMessage = { 'type': 'danger', 'msg': e.toString()};
    } catch(e) {
      errorMessage = { 'type': 'danger', 'msg': 'Unknown error $e'};
    } finally {
      isHttpLoading = false;
    }

  }

  ApplicationEditionComponent(RouteProvider routeProvide,this._parent,this.mdtQueryService){
    //super(mdtQueryService); MDTQueryService mdtQueryService,
  }
}