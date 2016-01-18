import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:logging/logging.dart';
import 'package:angular_ui/angular_ui.dart';
import 'lib/component/application.dart';
import 'lib/component/user.dart';
import 'lib/component/artifact.dart';
import 'lib/routing/mdt_router.dart';
import 'lib/service/mdt_query.dart';

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
  List<Map> currentRouteHistory = new List<Map>();
  void enterRoute(String routeName,String routePath,int level){
    //cut current History
    print("EnterRoute $routeName, level $level");
    print("History length ${currentRouteHistory.length}");
    if (currentRouteHistory.length >= level) {
      currentRouteHistory= currentRouteHistory.sublist(0, level );
    }
    print("History length ${currentRouteHistory.length}");
    currentRouteHistory.add({"name":routeName,"path":routePath});
    //special case for for home
    if (level ==0){
      //add link to apps
      currentRouteHistory.add({"name":"Applications","path":"/apps"});
    }
  }
  MainComponent mainComp;
  bool isUserConnected = false;
  bool isUserAdmin = false;
  Map currentUser = null;
  void userLogguedIn(Map user){
    print("userLogguedIn");
    currentUser = user;
    isUserConnected = true;
    isUserAdmin = (user["isSystemAdmin"] == true);
  }
}

@Component(
    selector: 'mdt_comp',
    templateUrl: 'pages/main_page.html',
    useShadowDom: false)
class MainComponent implements ScopeAware {
  void get isUserConnected => _scope.rootScope.context.isUserConnected;
 // bool isUserConnected = false;
  bool isHttpLoading = false;
  void get  currentUser => _scope.rootScope.context.currentUser;
  void get routeHistory => _scope.rootScope.context.currentRouteHistory;
  final Http _http;
  var lastAuthorizationHeader = '';

  Modal modal;
  ModalInstance modalInstance;
  Scope _scope;
  void get scope => _scope;
  void set scope(Scope scope) {
    _scope = scope;
    _scope.rootScope.context.enterRoute("Home","/home",0);
  }
 /* Scope currentScope;

  get scope => currentUser;
  void set scope(Scope scope) {
    currentScope = scope;
    scope.rootScope.context.mainComp = this;
  }*/
  // String backdrop = 'true';

  void displayRegisterPopup(){
    displayPopup("<register_comp></register_comp>");
    //modalInstance = modal.open(new ModalOptions(template:, backdrop: backdrop), scope);
  }
  void displayLoginPopup(){
    displayPopup("<login_comp></login_comp>");
  }


  void displayPopup(String template){
    modalInstance = modal.open(new ModalOptions(template:template, backdrop: 'true'),scope);
  }

  void hidePopup(){
    modal.hide();
  }

/*
  Map allHeaders({String contentType}){
    var requestContentType = contentType!=null ? contentType : 'application/json; charset=utf-8';
    var initialHeaders = {"content-type": requestContentType,"accept":'application/json'/*,"Access-Control-Allow-Headers":"*"*/};
    if (lastAuthorizationHeader.length > 0){
      initialHeaders['authorization'] = lastAuthorizationHeader;
    }else {
      initialHeaders.remove('authorization');
    }
    return initialHeaders;
  }
*/
  MainComponent(this._http,this.modal,MDTQueryService mdtService){
    print("Main component created $this");
    mdtService.setHttpService(_http);
    //scope.rootScope.context.mainComp = this;
/*
    RouteHandle route = routeProvider.route.newHandle();
    route.onEnter.listen((RouteEvent e){
      if (_scope != null) {
        _scope.rootScope.context.enterRoute("Home", "/home", 0);
        _scope.rootScope.context.enterRoute("Home", "/apps/", 1);
      }
    });*/
  }

  displayErrorFromResponse(HttpResponse response){

  }
}

void main() {
  Logger.root..level = Level.FINEST
    ..onRecord.listen((LogRecord r) { print(r.message); });

  print("s tart main");
  applicationFactory()
  .addModule(new AngularUIModule())
  .addModule(new MDTAppModule())
  .rootContextType(MDTRootScope)
  .run();
}
