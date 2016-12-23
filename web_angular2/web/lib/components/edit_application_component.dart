import 'dart:async';
import 'dart:html';
import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import '../commons.dart';

abstract class EditAppComponentAware {
  void updateNeeded();
}

@Component(
    selector: 'edit_app_comp',
    templateUrl: 'edit_application_component.html',
    directives: const [materialDirectives,ErrorComponent],
    providers: materialProviders
    )
class EditAppComponent extends BaseComponent{
  MDTQueryService _mdtQueryService;
  EditAppComponent(this._mdtQueryService, GlobalService globalService) : super.withGlobal(globalService);

  MDTApplication _application;
  var isModeEdition = false;
  EditAppComponentAware delegate;

  var appName = '';
  var appDescription = '';
  String appPlatform;
  String appIcon ="images/placeholder.jpg";
  File appIconFile;
  bool maxVersionCheckEnabled = false;

  @Input()
  void set parameters(Map<String,dynamic> params) {
      isModeEdition = params["isModeEdition"];
      application = params["application"];
      delegate = params["delegate"];
  }

  void set application(MDTApplication app){
    error = null;
    _application = app;
    if (isModeEdition && app != null){
      appName = app.name;
      appDescription = app.description;
      appPlatform = app.platform;
      appIcon = app.appIcon;
      maxVersionCheckEnabled = (app.maxVersionSecretKey!=null);
    }else {
      appName = '';
      appDescription = '';
      appPlatform;
      appIcon ="images/placeholder.jpg";
      maxVersionCheckEnabled = false;
    }
  }

  MDTApplication get application => _application;

  Future onInputChange(dynamic event) {
    var file = event.currentTarget.files.first;

    appIconFile = file;
    FileReader reader = new FileReader();
    reader.onLoadEnd.listen((e) => createImageElement(file,reader.result));
    reader.readAsDataUrl(file);
  }

  void createImageElement(File file,String base64) {
    //print(base64);
    appIcon = "$base64";
  }

  void createOrUpdateApp() {
      if (isModeEdition){
        _updateApp();
      }else {
        _createApp();
      }
  }

  Future _updateApp() async{
    error = null;
    if (isHttpLoading){
      return;
    }

    if (_checkParameter() == false){
      return;
    }
    try {
      isHttpLoading = true;
      MDTApplication appUpdated = await _mdtQueryService.updateApplication(application.uuid, appName,appDescription,appIconFile != null ? appIcon : null,maxVersionCheckEnabled);
      if (appUpdated !=null){
        delegate?.updateNeeded();
        //global_service.loadAppsIfNeeded(forceRefresh:true);
        //caller.applicationEditionSucceed(appUpdated);
        // caller.applicationListNeedBeReloaded();
        error = new UIError(' Application ${appUpdated.name} updated successfully!',"",ErrorType.SUCCESS);
      }else {
        error = new UIError('/!\ Unknown error',"",ErrorType.ERROR);
      }
    } on ApplicationError catch(e) {
      error = new UIError(ApplicationError.errorCode,e.message,ErrorType.ERROR);
    } catch(e) {
      error = new UIError("Unknown Error","$e",ErrorType.ERROR);
    } finally {
      isHttpLoading = false;
    }

  }

  Future _createApp() async{
    error = null;
    if (isHttpLoading){
      return;
    }

    if (_checkParameter() == false){
      return;
    }
    try {
      isHttpLoading = true;
      MDTApplication appCreated = await _mdtQueryService.createApplication(appName,appDescription,appPlatform,appIcon,maxVersionCheckEnabled);
      if (appCreated !=null){
        delegate?.updateNeeded();
        //caller.applicationEditionSucceed(appCreated);
       // global_service.loadAppsIfNeeded(forceRefresh:true);
        error = new UIError('Application ${appCreated.name} created successfully!',"",ErrorType.SUCCESS);
      }else {
        error = new UIError('/!\ Unknown error',"",ErrorType.ERROR);
      }
    } on ApplicationError catch(e) {
      error = new UIError(ApplicationError.errorCode,e.message,ErrorType.ERROR);
    } catch(e) {
      error = new UIError("Unknown Error","$e",ErrorType.ERROR);
    } finally {
      isHttpLoading = false;
    }

  }

  bool _checkParameter(){
    if (appName == null){
      error = new UIError('Application name can not be null.',"",ErrorType.WARNING);
      return false;
    }
    if (appDescription == null){
      error = new UIError('Application description can not be null.',"",ErrorType.WARNING);
      return false;
    }
    if (appPlatform == null){
      error = new UIError('Please select a platform.',"",ErrorType.WARNING);
      return false;
    }
    if (appIconFile != null && appIconFile.size > 200*1024 ){
      error = new UIError('Icon too big (max:200k).',"",ErrorType.WARNING);
      return false;
    }
    return true;
  }
}