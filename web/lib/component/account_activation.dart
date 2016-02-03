import 'package:angular/angular.dart';
import 'dart:core';
import 'dart:async';
import 'dart:html';
import 'base_component.dart';
import 'application_detail.dart';
import '../model/mdt_model.dart';
import '../model/errors.dart';
import '../service/mdt_query.dart';

@Component(
    selector: 'account_activation',
    templateUrl: 'account_activation.html',
    useShadowDom: false)
class AccountActivationComponent extends BaseComponent {
  AccountActivationComponent(LocationWrapper location,MDTQueryService mdtQueryService){
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
      }
  }
}