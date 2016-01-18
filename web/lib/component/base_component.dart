import 'package:angular/angular.dart';

class BaseComponent implements ScopeAware {
  bool isHttpLoading = false;
  var errorMessage = null;

  void hideMessage() {
    errorMessage = null;

    void hideMessage() {
      errorMessage = null;
    }
  }

  Scope _scope;

  void get scope => _scope;
  void set scope(Scope scope) {
    _scope = scope;
    if (currentRoute != null) {
      _scope.rootScope.context.enterRoute(
          currentRoute["name"], currentRoute["path"], currentRoute["level"]);
    }
  }

  Map currentRoute = null;

  /* BaseComponent(this._mdtService){

  }*/

  MainComponent mainComp() {
    return _scope.parentScope.context;
  }

  //MDTQueryService _mdtService;

//bool isHttpLoading = false;
}