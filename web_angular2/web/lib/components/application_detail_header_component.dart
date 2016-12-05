import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'dart:async';
import '../commons.dart';

@Component(
    selector: 'application_detail_header',
    directives: const [ErrorComponent],
    templateUrl: 'application_detail_header_component.html')
class ApplicationDetailHeaderComponent extends BaseComponent {
  @Input()
  MDTApplication application;

  MDTQueryService _mdtQueryService;
  bool get maxVersionEnabled => (application != null && application.maxVersionSecretKey != null);
  bool isMaxVersionEnabledCollapsed = true;
  bool isAdminUsersCollapsed = true;

  bool get isFavorite => global_service.isAppFavorite(application.uuid);

  ApplicationDetailHeaderComponent(this._mdtQueryService, GlobalService globalService) : super.withGlobal(globalService);

  bool canAdmin(){
    bool displayAdminOption  = global_service.adminOptionsDisplayed;
    if (global_service.connectedUser.isSystemAdmin && displayAdminOption){
      return true;
    }
    var email = global_service.connectedUser.email.toLowerCase();
    var adminFound =  application.adminUsers.firstWhere((o) => o.email!=null ? (o.email.toLowerCase() == email) : false, orElse: () => null);

    if (adminFound != null && displayAdminOption){
      return true;
    }
    return false;
  }

  void toggleAdministrators(){
    isAdminUsersCollapsed = !isAdminUsersCollapsed;
  }
  void toggleFavorite(){

  }

  Future addAdministrator(String email) async{
    error = null;
    try {
      isHttpLoading = true;
      await _mdtQueryService.addAdministrator(application,email);
      loadApp();
    }catch(e) {
      error = new UIError(ConnectionError.errorCode,e.message,ErrorType.ERROR);
    } finally {
      isHttpLoading = false;
    }
  }

  Future deleteAdministrator(String email) async{
    error = null;
    try {
      isHttpLoading = true;
      await _mdtQueryService.deleteAdministrator(application,email);
      loadApp();
    }catch(e) {
      error = new UIError(ConnectionError.errorCode,e.message,ErrorType.ERROR);
    } finally {
      isHttpLoading = false;
    }
  }

  Future loadApp() async{
    error = null;
    try {
      isHttpLoading = true;
      var app= await _mdtQueryService.getApplication(application.uuid);
      application = app;
      //await loadAppVersions();

    } on ApplicationError catch(e) {
      error = new UIError(ConnectionError.errorCode,e.message,ErrorType.ERROR);
    } catch(e) {
      error = new UIError(ConnectionError.errorCode,'Unknown error $e',ErrorType.ERROR);
    } finally {
      isHttpLoading = false;
    }
  }
}