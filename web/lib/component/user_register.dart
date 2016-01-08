import 'package:angular/angular.dart';
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

  void registerUser(String username,String email, String password) async {
    var response = null;
    try {
      isHttpLoading = true;
      response = await mdtQueryService.registerUser(username,email,password);
    } on RegisterError catch(e) {
      errorMessage = { 'type': 'danger', 'msg': e.toString()};
      return;
    } catch(e) {
      errorMessage = { 'type': 'danger', 'msg': 'Unknown error $e'};
      return;
    } finally {
      isHttpLoading = false;
    }

    if (response["status"] == 200){
      errorMessage = { 'type': 'success', 'msg': 'Registration completed: $response'};
    }else {
      errorMessage = { 'type': 'danger', 'msg': 'Unknown error: $response'};
    }
    /*
    print("register ${scope.rootScope.context.globalValue}");
    String url = "${scope.rootScope.context.mdtServerApiRootUrl}/users/v1/register";
    var userRegistration = {"email":"$email", "password":"$password", "name":"$username"};
    isHttpLoading = true;
    isCollapsed = true;
    var response =  await mainComp().sendRequest('POST', url, body:JSON.encode(userRegistration));
    isHttpLoading = false;
    isCollapsed = false;
    if (response.status == 200){
      message = "Registration completed :${response.responseText["data"]}";
    }else {
      if (response.status == 0){
        message = "Login failed, Error :${response}";
      }else {
        message = "Login failed, Error :${response.responseText}";
      }
    }*/
  }

  RegisterComponent(this.mdtQueryService){
    print("RegisterComponent created: ");
  }
}