import 'package:angular/angular.dart';
import 'dart:core';
import 'dart:async';
import 'base_component.dart';
import '../model/errors.dart';
import '../service/mdt_query.dart';

@Component(
    selector: 'account_activation',
    templateUrl: 'account_activation.html',
    useShadowDom: false)
class AccountActivationComponent extends BaseComponent {
  bool activationError = false;
  MDTQueryService mdtQueryService;
  AccountActivationComponent(LocationWrapper location,this.mdtQueryService){
    var currentLocation = location.location.href;
    var parameters = Uri.splitQueryString(currentLocation);

    //find token parameters
    var token = null;
    for(String key in parameters.keys){
      if (key.endsWith("activation?token")){
        token = parameters[key];
      }
    }

    if (token != null){
      print("Activation token  found ${token}");
      checkToken(token);
    }
  }

  Future checkToken(String token) async{
    try{
      activationError = false;
      isHttpLoading = true;
      await mdtQueryService.activateUser(token);
      activationError = false;
    }on ActivationError catch(e){
      activationError = true;
      errorMessage = e.toString();
    }
    catch(e){
      activationError = true;
    }finally {
      isHttpLoading = false;
    }
  }
}