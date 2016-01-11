import 'package:angular/angular.dart';
import 'base_component.dart';
import '../service/mdt_query.dart';
import '../model/errors.dart';

@Component(
    selector: 'login_comp',
    templateUrl: 'user_login.html',
    useShadowDom: false
)
class LoginComponent extends BaseComponent {
  String email="";
  String password="";


  NgRoutingHelper locationService;
  MDTQueryService mdtQueryService;


  String backdrop = 'true';
  //@NgTwoWay('isHttpLoading')

  @NgTwoWay('isCollapsed')
  bool isCollapsed = true;



  void loginUser(String email, String password) async {
    var response = null;
    try {
      isHttpLoading = true;
      response = await mdtQueryService.loginUser(email, password);
    } on LoginError catch(e) {
      errorMessage = { 'type': 'danger', 'msg': e.toString()};
      return;
    } catch(e) {
      errorMessage = { 'type': 'danger', 'msg': 'Unknown error $e'};
      return;
    } finally {
      isHttpLoading = false;
    }


    if (response["status"] == 200){
      //hide popup
      mainComp().isUserConnected= true;
      mainComp().currentUser = response["data"];
      mainComp().hidePopup();
      locationService.router.go('apps',{});
    }else {
      errorMessage = { 'type': 'danger', 'msg': 'Unknown error: $response'};
    }

      /*
    String url = "${scope.rootScope.context.mdtServerApiRootUrl}/users/v1/login";
    var userLogin = {"email":"$email", "password":"$password"};
    isHttpLoading = true;
    var response =  await mainComp().sendRequest('POST', url, body:'username=${email}&password=${password}', contentType:'application/x-www-form-urlencoded');
    */
    /*
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
    }*/
  }

  LoginComponent(this.locationService,this.mdtQueryService){
    print("LoginComponent created: ");
    // mainComp = scope.parentScope.context;
  }
}