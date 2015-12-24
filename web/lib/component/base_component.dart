import 'package:angular/angular.dart';

class BaseComponent  implements ScopeAware {
  MainComponent mainComp(){
    return scope.parentScope.context;
  }
  Scope scope;
  bool isHttpLoading = false;
}