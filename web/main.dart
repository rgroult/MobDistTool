import 'package:angular/angular.dart';
import 'package:logging/logging.dart';
import 'package:angular/application_factory.dart';
import 'dart:async';
import 'pages/users_list.dart';
import 'pages/apps_list.dart';
import 'pages/artifacts_list.dart';
import 'package:hammock/hammock.dart';


void MDTRouteInitializer(Router router, RouteViewFactory views) {
  print("views.configure");
  views.configure({
    'home': ngRoute(
        path: '/home',
        defaultRoute : true,
        view: 'pages/home.html'),
    'app': ngRoute(
        path: '/apps',
        view: 'pages/apps.html',
          mount: {
            'artifacts': ngRoute(
            path: '/:appId/artifacts',
            view: 'pages/artifacts.html')}),
    'users': ngRoute(
        path: '/users',
        view: 'pages/users.html')
  });
}

@Component(
    selector: 'test_comp')
class TestComponent {
  TestComponent(globalComponent global){
    print("test component created");
  }
}

@Injectable()
class globalComponent {
  final Http _http;
  String currentAuthenticationHeader;
  LoginComponent(this._http) {
    print("login component created");
  }

  void testUser(){
    loginUser('toto','ttii');
  }

  void loginUser(String email, String password) async{
    print("log user $email, $password");
    String mdtServerUrl = "http://localhost:8080/";
    var response =  await sendRequest(_http,'POST', '${mdtServerUrl}/api/users/v1/login', body:'username=${email}&password=${password}', contentType:'application/x-www-form-urlencoded');
    print("response ${response.body}");
  }

  var lastAuthorizationHeader = '';

  Map allHeaders({String contentType}){
    var requestContentType = contentType!=null ? contentType : 'application/json; charset=utf-8';
    var initialHeaders = {"content-type": requestContentType,"accept":'application/json'};
    if (lastAuthorizationHeader.length > 0){
      initialHeaders['authorization'] = lastAuthorizationHeader;
    }else {
      initialHeaders.remove('authorization');
    }
    return initialHeaders;
  }

  Future<http.Response> sendRequest(Http http,String method, String url, {String query, String body,String contentType}) {
    //var url = '$baseUrlHost$path';
    if (query != null){
      url = '$url$query';
    }
    var headers = contentType == null? allHeaders(): allHeaders(contentType:contentType);
    var httpBody = body;
    if (body ==null) {
      httpBody ='';
    }
    switch (method) {
      case 'GET':
        return http.get(url,headers:allHeaders(contentType:contentType));
      case 'POST':
        return http.post(url,headers:headers,body:httpBody);
      case 'PUT':
        return http.put(url,headers:headers,body:httpBody);
      case 'DELETE':
        return http.delete(url,headers:headers);
    }
    return null;
  }
}

class MDTAppModule extends Module {
  final String mdtServerUrl = "http://localhost:8080/";
  MDTAppModule() {
    bind(UsersComponent);
    bind(ApplicationsComponent);
    bind(ArtifactsComponent);
    bind(TestComponent);
    bind(RouteInitializerFn, toValue: MDTRouteInitializer);
    bind(NgRoutingUsePushState, toValue: new NgRoutingUsePushState.value(false));
  }
}

void main() {
  Logger.root..level = Level.FINEST
    ..onRecord.listen((LogRecord r) { print(r.message); });

  print("main");
  applicationFactory()
  .rootContextType(globalComponent)
  .addModule(new MDTAppModule())
  .run();
}