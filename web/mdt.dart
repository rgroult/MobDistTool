import 'package:angular/angular.dart';
import 'package:logging/logging.dart';
import 'package:angular/application_factory.dart';
import 'dart:async';
import 'pages/users_list.dart';
import 'pages/apps_list.dart';
import 'pages/artifacts_list.dart';
import 'pages/main_page.dart';

@Component(
    selector: 'test_comp')
class TestComponent {
  String testValue = "toto";
  TestComponent(){
    print("test component created $this");
  }
}
/*
@Component(
    selector: 'main_comp',
    templateUrl: 'main.html',
    useShadowDom: false)
class MainComponent {
  final Http _http;
  MainComponent(this._http){
    print("Main component created $this");
  }
}
*/
@Component(
    selector: 'test_sibling_comp')
class TestSiblingComponent {
  TestSiblingComponent(TestComponent test){
    print("test sibling component created ${test.testValue} ");
   // testfunc();
  }
}

@Injectable(
)
class globalComponent {
  final Http _http;
  String currentAuthenticationHeader;
  String globalValue = "globalValue";

  void testfunc(){
    print("testfunc");
  }
  globalComponent() {
    print("global component created");
  }
}

class MDTAppModule extends Module {
  final String mdtServerUrl = "http://localhost:8080/";
  MDTAppModule() {
    bind(TestComponent);
    bind(TestSiblingComponent);
    bind(MainComponent);
    bind(NgRoutingUsePushState, toValue: new NgRoutingUsePushState.value(false));
  }
}

void main() {
  Logger.root..level = Level.FINEST
    ..onRecord.listen((LogRecord r) { print(r.message); });

  print("main");
  applicationFactory()
  .addModule(new MDTAppModule())
  .rootContextType(globalComponent)
  .run();
}