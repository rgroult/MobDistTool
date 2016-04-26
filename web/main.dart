import 'dart:html' hide Platform;
import 'dart:math';
import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:logging/logging.dart';
import 'package:angular_ui/angular_ui.dart';
import 'lib/component/application.dart';
import 'lib/component/user.dart';
import 'lib/component/artifact.dart';
import 'lib/routing/mdt_router.dart';
import 'lib/service/mdt_query.dart';
import 'version.dart' as version;
import 'lib/model/mdt_model.dart';

class MDTAppModule extends Module {
  MDTAppModule() {
    install (new MDTApplicationModule());
    install (new MDTArtifactModule());
    install (new MDTUserModule());
    bind(MainComponent);
    bind(RouteInitializerFn, toValue: MDTRouteInitializer);
    bind(MDTQueryService, toValue:new MDTQueryService());
    bind(NgRoutingUsePushState, toValue: new NgRoutingUsePushState.value(false));
  }
}

@Injectable()
class MDTRootScope {
  //global config and context
  List<Map> get currentRouteHistory => isUserConnected ? routeHistory : routeHistory.sublist(0,min(routeHistory.length,1));
  MainComponent mainComp;
  bool get isUserConnected => (currentUser!=null);
  bool get isUserAdmin => (currentUser!=null) && (currentUser.isSystemAdmin == true);
  MDTUser currentUser = null;
  bool adminOptionsDisplayed = false;
  Platform currentDevice = Platform.OTHER;

  void userLogguedIn(MDTUser user){
    print("userLogguedIn");
    currentUser = user;
    /*isUserConnected = true;
    isUserAdmin = (user["isSystemAdmin"] == true);*/
  }

  MDTRootScope(){
    //Detect browser
    var userAgent = window.navigator.appVersion.toUpperCase();
    if (userAgent.indexOf("ANDROID") != -1){
      currentDevice = Platform.ANDROID;
    }else if ((userAgent.indexOf("IPAD") != -1) || (userAgent.indexOf("IPHONE") != -1) || (userAgent.indexOf("IPOD") != -1)){
      currentDevice  = Platform.IOS;
    }
    print("Platform detected $currentDevice  user agent $userAgent");
  }
}

@Component(
    selector: 'mdt_comp',
    templateUrl: 'pages/main_page.html',
    useShadowDom: false)
class MainComponent implements ScopeAware,MDTQueryServiceAware {
  bool get isUserConnected => scope.rootScope.context.isUserConnected;
 // bool isUserConnected = false;
  bool isHttpLoading = false;
  String get mdt_version => version.MDT_VERSION;
  bool get isSystemAdmin => scope.rootScope.context.isUserAdmin;
  Map get  currentUser => scope.rootScope.context.currentUser;
  List<Map> get routeHistory => scope.rootScope.context.currentRouteHistory;
  final Http _http;
  NgRoutingHelper locationService;
  MDTQueryService mdtService;
  //var lastAuthorizationHeader = '';

  @NgTwoWay('adminOption')
  bool get adminOption => scope.rootScope.context.adminOptionsDisplayed;
  void set adminOption(bool option){
    scope.rootScope.context.adminOptionsDisplayed = option;
  }

  Modal modal;
  ModalInstance modalInstance;
  Scope scope;

  void loginExceptionOccured(){
    logout();
    displayLoginPopup();
  }

  void displayRegisterPopup(){
    displayPopup("<register_comp></register_comp>");
    //modalInstance = modal.open(new ModalOptions(template:, backdrop: backdrop), scope);
  }
  void displayLoginPopup(){
    displayPopup("<login_comp></login_comp>");
  }


  void displayPopup(String template){
    modalInstance = modal.open(new ModalOptions(template:template, backdrop: 'false'),scope);
  }

  void hidePopup(){
    modal.hide();
  }

  void logout(){
    scope.rootScope.context.currentUser = null;
    mdtService.lastAuthorizationHeader = '';
    locationService.router.go('home',{});
  }
  MainComponent(this._http,LocationWrapper location, HttpInterceptors interceptors,this.modal,this.mdtService,this.locationService){
    print("Main component created $this");
    mdtService.setHttpService(this,_http,location);
    mdtService.configureInjector(interceptors);
  }

  displayErrorFromResponse(HttpResponse response){

  }
}

void main() {
  Logger.root..level = Level.FINEST
    ..onRecord.listen((LogRecord r) { print(r.message); });

  print("start main");
  applicationFactory()
  .addModule(new AngularUIModule())
  .addModule(new MDTAppModule())
  .rootContextType(MDTRootScope)
  .run();
}
