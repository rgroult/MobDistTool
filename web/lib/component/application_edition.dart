import 'package:angular/angular.dart';
import 'dart:async';
import 'dart:html';
import 'base_component.dart';
import 'application_list.dart';
import '../service/mdt_query.dart';
import '../model/errors.dart';
import '../model/mdt_model.dart';

@Decorator(
    selector: 'input[type=file][file-model]',
    map: const {'file-model': '&filesSelected'})
class FileModel {
  Element inputElement;
  String expression;
  final Scope scope;
  List<File> files;
  var listeners = {};

  FileModel(this.inputElement, this.scope) {
  }

  initListener(var stream, var handler) {
    int key = stream.hashCode;
    if (!listeners.containsKey(key)) {
      listeners[key] = handler;
      stream.listen((event) => handler({r"files": (inputElement as InputElement).files}));
    }
  }

  set filesSelected(value)  =>  initListener(inputElement.onChange, value);
}

@Component(
    selector: 'application_edition',
    templateUrl: 'application_edition.html',
    useShadowDom: false
)
class ApplicationEditionComponent extends BaseComponent {
  @NgOneWay('caller')
  ApplicationListComponent caller;
 // ApplicationDetailComponent _parentDetail;
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
    appIcon = app.appIcon;
    maxVersionCheckEnabled = (app.maxVersionSecretKey!=null);
  }
  String appName;
  String appPlatform;
  String appDescription;
  String appUUID;
  String appIcon ="images/placeholder.jpg";
  File appIconFile;
  bool maxVersionCheckEnabled = false;

  void hideMessage(){
    errorMessage = null;
  }

  Future upfilesSelected(dynamic values) async{
    File file = values.first;
 /*   if (file.type.isNotEmpty && file.type.matchAsPrefix("image/") == null){
      appIcon = "images/placeholderImage.jpg";
      appIconFile = null;
      return;
    }*/
    appIconFile = file;
    FileReader reader = new FileReader();
    reader.onLoadEnd.listen((e) => createImageElement(file,reader.result));
    reader.readAsDataUrl(file);
  }

  void createImageElement(File file,String base64) {
    //print(base64);
    appIcon = "$base64";
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
    if (appIconFile != null && appIconFile.size > 200*1024 ){
      errorMessage = { 'type': 'warning', 'msg': 'Icon too big (max:200k).' };
      return false;
    }
    return true;
  }

  Future updateApp() async{
    errorMessage = null;
    if (isHttpLoading){
      return;
    }

    if (checkParameter() == false){
      return;
    }
    try {
      isHttpLoading = true;
      MDTApplication appUpdated = await mdtQueryService.updateApplication(appUUID, appName,appDescription,appIconFile != null ? appIcon : null,maxVersionCheckEnabled);
      if (appUpdated !=null){
        caller.applicationEditionSucceed(appUpdated);
       // caller.applicationListNeedBeReloaded();
        errorMessage = { 'type': 'success', 'msg': ' Application ${appUpdated.name} updated successfully!'};
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

  Future createApp() async{
    errorMessage = null;
    if (isHttpLoading){
      return;
    }

    if (checkParameter() == false){
      return;
    }
    try {
      isHttpLoading = true;
      MDTApplication appCreated = await mdtQueryService.createApplication(appName,appDescription,appPlatform,appIcon,maxVersionCheckEnabled);
      if (appCreated !=null){
          caller.applicationEditionSucceed(appCreated);
        errorMessage = { 'type': 'success', 'msg': ' Application ${appCreated.name} created successfully!'};
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

  ApplicationEditionComponent(RouteProvider routeProvide,this.mdtQueryService){
    //super(mdtQueryService); MDTQueryService mdtQueryService,
  }
}