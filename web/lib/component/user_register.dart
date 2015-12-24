import 'package:angular/angular.dart';
import 'base_component.dart';

@Component(
    selector: 'register_comp',
    templateUrl: 'user_register.html',
    useShadowDom: false
)
class RegisterComponent extends BaseComponent  {
  String username ="";
  String email="";
  String password="";
  String backdrop = 'true';
  //@NgTwoWay('isHttpLoading')
  //bool isHttpLoading = false;
  @NgTwoWay('isCollapsed')
  bool isCollapsed = true;
  String message ="mesage";

  void registerUser(String username,String email, String password) async {
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
    }
  }

  RegisterComponent(){
    print("RegisterComponent created: ");
  }
}