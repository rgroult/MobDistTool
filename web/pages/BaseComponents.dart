import 'package:angular/angular.dart';
import 'package:angular_ui/angular_ui.dart';

class BaseComponent  implements ScopeAware {
  MainComponent mainComp(){
    return scope.parentScope.context;
  }
  Scope scope;
  bool isHttpLoading = false;
}