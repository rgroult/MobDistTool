import 'package:angular/angular.dart';
import 'package:logging/logging.dart';
import 'package:angular/application_factory.dart';
import 'package:angular_ui/angular_ui.dart';
import 'dart:async';
import 'pages/users_list.dart';
import 'pages/apps_list.dart';
import 'pages/artifacts_list.dart';
import 'pages/main_page.dart';

void MDTRouteInitializer(Router router, RouteViewFactory views) {
  print("views.configure");
  views.configure({
    'home': ngRoute(
        path: '/home',

        view: 'pages/home.html'),
    'apps': ngRoute(
        path: '/apps',
        defaultRoute : true,
        viewHtml: '<apps_list></apps_list>',
        //view: 'pages/apps_list.html',
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
  String testValue = "toto";
  TestComponent(){
    print("test component created $this");
  }
}


@Component(
    selector: 'test_sibling_comp')
class TestSiblingComponent {
  TestSiblingComponent(TestComponent test){
    print("test sibling component created ${test.testValue} ");
   // testfunc();
  }
}

@Component(
    selector: 'loading_comp',
    template:'<h2>Loading...</h2>'
)
class LoadingComponent {
  LoadingComponent(){
  }
}


@Injectable(
)
class globalComponent {
  final Http _http;
  String currentAuthenticationHeader;
  String globalValue = "globalValue";
  final String mdtServerUrl = "http://localhost:8080/";
  final String mdtServerApiRootUrl = "http://localhost:8080/api";

  void testfunc(){
    print("testfunc");
  }
  globalComponent() {
    print("global component created");
  }
}

class MDTAppModule extends Module {

  MDTAppModule() {
    bind(TestComponent);
    bind(TestSiblingComponent);
    bind(MainComponent);
    bind(RegisterComponent);
    bind(LoginComponent);
    bind(LoadingComponent);
    bind(ApplicationsComponent);
    bind(RouteInitializerFn, toValue: MDTRouteInitializer);
    bind(NgRoutingUsePushState, toValue: new NgRoutingUsePushState.value(false));
  }
}

void main() {
  Logger.root..level = Level.FINEST
    ..onRecord.listen((LogRecord r) { print(r.message); });

  print("main");
  applicationFactory()
  .addModule(new AngularUIModule())
  .addModule(new MDTAppModule())
  .rootContextType(globalComponent)
  .run();
}