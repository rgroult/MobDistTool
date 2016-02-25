import 'dart:async';
import 'package:angular/angular.dart';
import 'package:validator/validator.dart';
import 'base_component.dart';
import '../service/mdt_query.dart';
import '../model/errors.dart';

@Component(
    selector: 'register_comp',
    templateUrl: 'user_register.html',
    useShadowDom: false
)
class RegisterComponent extends BaseComponent  {
  String username ="";
  String email="";
  String password="";
  MDTQueryService mdtQueryService;

  bool checkParameters(String username,String email, String password){
    if (isEmail(email) == false) {
      errorMessage = { 'type': 'danger', 'msg': 'Invalid email format'};
      return false;
    }
    if (username == null){
      errorMessage = { 'type': 'danger', 'msg': 'name must not be empty'};
      return false;
    }
    if (password == null){
      errorMessage = { 'type': 'danger', 'msg': 'password must not be empty'};
      return false;
    }
    return true;
  }

  Future registerUser(String username,String email, String password) async {
    errorMessage = null;
    var response = null;
    if (checkParameters(username,email,password) == false){
      return;
    }
    try {
      isHttpLoading = true;
      response = await mdtQueryService.registerUser(username,email,password);
      if (response["status"] == 200){
        errorMessage = { 'type': 'success', 'msg': 'Registration completed: $response'};
      }else {
        errorMessage = { 'type': 'danger', 'msg': 'Unknown error: $response'};
      }
    } on RegisterError catch(e) {
      errorMessage = { 'type': 'danger', 'msg': e.toString()};
    } catch(e) {
      errorMessage = { 'type': 'danger', 'msg': 'Unknown error $e'};
    } finally {
      isHttpLoading = false;
    }
  }

  RegisterComponent(this.mdtQueryService){
    print("RegisterComponent created: ");
  }
}