import 'package:angular/angular.dart';

class BaseComponent implements ScopeAware {
  bool isHttpLoading = false;
  var errorMessage = null;

  void hideMessage() {
    errorMessage = null;
  }

  Scope scope;

  /*MainComponent mainComp() {
    return scope.parentScope.context;
  }
*/
  //MDTQueryService _mdtService;

//bool isHttpLoading = false;
}