import 'package:angular/angular.dart';
import '../service/mdt_query.dart';

class BaseComponent  implements ScopeAware {

 /* BaseComponent(this._mdtService){

  }*/

  MainComponent mainComp(){
    return scope.parentScope.context;
  }
  MDTQueryService _mdtService;
  Scope scope;
  bool isHttpLoading = false;
}