import 'package:angular/angular.dart';

class BaseComponent  implements ScopeAware {
 bool isHttpLoading = false;
 var errorMessage = null;

 void hideMessage(){
  errorMessage = null;
 }
 /* BaseComponent(this._mdtService){

  }*/

  MainComponent mainComp(){
 /*  return scope.rootScope.context.mainComp;
   var currentScope = scope.parentScope;
   while (!(currentScope.context is MainComponent) && currentScope!= scope.rootScope){
    currentScope = currentScope.parentScope;
   }
   return currentScope.context;*/
    return scope.parentScope.context;
  }
  //MDTQueryService _mdtService;
  Scope scope;
  //bool isHttpLoading = false;
}