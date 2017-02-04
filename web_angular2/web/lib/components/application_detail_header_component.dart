import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';
import 'dart:async';
import '../services/modal_service.dart';
import '../commons.dart';
import '../components/edit_application_component.dart';

@Component(
    selector: 'application_detail_header',
    directives: const [ErrorComponent,materialDirectives],
    providers: materialProviders,
    templateUrl: 'application_detail_header_component.html')
class ApplicationDetailHeaderComponent extends BaseComponent implements OnInit,EditAppComponentAware {
  @Input()
  MDTApplication application;
  @Output()
  var appUpdated = new EventEmitter();

  final Router _router;
  MDTQueryService _mdtQueryService;
  ModalService _modalService;
  bool get maxVersionEnabled => (application != null && application.maxVersionSecretKey != null);
  bool isMaxVersionEnabledCollapsed = true;
  bool isAdminUsersCollapsed = true;
  String administratorToAdd ="";
  bool showDeleteDialog = false;


  bool get isFavorite => global_service.isFavorite(application.uuid);
  bool get canAdmin => canAdministrate(application);

  ApplicationDetailHeaderComponent(this._router,this._mdtQueryService,this._modalService, GlobalService globalService) : super.withGlobal(globalService);

  Future ngOnInit() async {
    loadApp();
  }
/*
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
*/
  void toggleAdministrators(){
    isAdminUsersCollapsed = !isAdminUsersCollapsed;
  }
  void toggleFavorite(){
    global_service.toggleFavorite(application.uuid);
  }

  Future deleteApplication() async {
    bool applicationisDeleted = await _mdtQueryService.deleteApplication(application);
    if(applicationisDeleted){
        await global_service.loadAppsIfNeeded(forceRefresh: true);
        _router.navigate(['Apps']);
    }else {
      error = new UIError("Error",'Unable to delete application',ErrorType.ERROR);
    }
  }
/*
  mdtQueryService.deleteApplication(currentApp).then((result){
  if (result){
  //return to app
  _parent.applicationListNeedBeReloaded();
  _parent.locationService.router.go('apps',{});
  }else{
  errorMessage = {'type': 'danger', 'msg': 'Unable to delete application'};
  }
  });*/

  Future addAdministrator(String email) async{
    if (email.length == 0 ){
      return;
    }
    error = null;
    try {
      isHttpLoading = true;
      await _mdtQueryService.addAdministrator(application,email);
      loadApp();
    }catch(e) {
      error = new UIError("ERROR","$e",ErrorType.ERROR);
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
      error = new UIError("ERROR","$e",ErrorType.ERROR);
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
      appUpdated.emit(app);

    } on ApplicationError catch(e) {
      error = new UIError(ConnectionError.errorCode,e.message,ErrorType.ERROR);
    } catch(e) {
      error = new UIError(ConnectionError.errorCode,'Unknown error $e',ErrorType.ERROR);
    } finally {
      isHttpLoading = false;
    }
  }

  void editApplication(){
    _modalService.displayEditApplication(application,this);
  }

  void updateNeeded(){
    loadApp();
  }
}
