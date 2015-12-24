import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:logging/logging.dart';
import 'package:angular_ui/angular_ui.dart';
import 'lib/component/application.dart';
import 'lib/component/user.dart';
import 'lib/component/artifact.dart';
import 'lib/routing/mdt_router.dart';

class MDTAppModule extends Module {
  MDTAppModule() {
    install (new MDTApplicationModule());
    install (new MDTArtifactModule());
    install (new MDTUserModule());
    bind(MainComponent);
    bind(RouteInitializerFn, toValue: MDTRouteInitializer);
    bind(NgRoutingUsePushState, toValue: new NgRoutingUsePushState.value(false));
  }
}

@Component(
    selector: 'mdt_comp',
    templateUrl: 'main_page.html',
    useShadowDom: false)
class MainComponent implements ScopeAware {
  Boolean isUserConnected = false;
  Boolean isHttpLoading = false;
  Map currentUser = null;
  final Http _http;
  var lastAuthorizationHeader = '';

  Modal modal;
  ModalInstance modalInstance;
  Scope scope;
  // String backdrop = 'true';

  void displayRegisterPopup(){
    displayPopup("<register_comp></register_comp>");
    //modalInstance = modal.open(new ModalOptions(template:, backdrop: backdrop), scope);
  }
  void displayLoginPopup(){
    displayPopup("<login_comp></login_comp>");
  }


  void displayPopup(String template){
    modalInstance = modal.open(new ModalOptions(template:template, backdrop: true),scope);
  }

  void hidePopup(){
    modal.hide();
  }


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

  MainComponent(this._http,this.modal){
    print("Main component created $this");
  }

  displayErrorFromResponse(HttpResponse response){

  }

  http.Response sendRequest(String method, String url, {String query, String body,String contentType}) async {
    //var url = '$baseUrlHost$path';
    Http http = this._http;
    if (query != null){
      url = '$url$query';
    }
    var headers = contentType == null? allHeaders(): allHeaders(contentType:contentType);
    var httpBody = body;
    if (body ==null) {
      httpBody ='';
    }
    try{
      switch (method) {
        case 'GET':
          return await http.get(url,headers:allHeaders(contentType:contentType));
        case 'POST':
          return await http.post(url,httpBody,headers:headers);
        case 'PUT':
          return await http.put(url,httpBody,headers:headers);
        case 'DELETE':
          return await http.delete(url,headers:headers);
      }
    } catch (e) {
      print("error $e");
      return e;
    }
    return null;
  }
}

void main() {
  Logger.root..level = Level.FINEST
    ..onRecord.listen((LogRecord r) { print(r.message); });

  print("start main");
  applicationFactory()
  .addModule(new AngularUIModule())
  .addModule(new MDTAppModule())
  .run();
}
