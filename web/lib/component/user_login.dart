import 'package:angular/angular.dart';
import 'base_component.dart';

@Component(
    selector: 'login_comp',
    templateUrl: 'user_login.html',
    useShadowDom: false
)
class LoginComponent extends BaseComponent {
  String email="";
  String password="";

  String backdrop = 'true';
  //@NgTwoWay('isHttpLoading')
  bool isHttpLoading = false;
  @NgTwoWay('isCollapsed')
  bool isCollapsed = true;
  String errorMessage ="message";
  NgRoutingHelper locationService;

  void loginUser(String email, String password) async {
    String url = "${scope.rootScope.context.mdtServerApiRootUrl}/users/v1/login";
    var userLogin = {"email":"$email", "password":"$password"};
    isHttpLoading = true;
    var response =  await mainComp().sendRequest('POST', url, body:'username=${email}&password=${password}', contentType:'application/x-www-form-urlencoded');
    if (response.status == 200){
      //hide popup
      mainComp().isUserConnected= true;
      mainComp().currentUser = response.responseText["data"];
      mainComp().hidePopup();
      locationService.router.go('apps',{});
    }else  if (response.status == 401){
      isCollapsed = false;
      errorMessage = "Login failed, Bad login or password.";
    }else {
      isCollapsed = false;
      if (response.status == 0){
        errorMessage = "Login failed, Error :${response}";
      }else {
        errorMessage = "Login failed, Error :${response.responseText}";
      }
    }
  }

  LoginComponent(this.locationService){
    print("LoginComponent created: ");
    // mainComp = scope.parentScope.context;
  }
}