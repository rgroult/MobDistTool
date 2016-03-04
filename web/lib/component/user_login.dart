import 'package:angular/angular.dart';
import 'package:angular_ui/angular_ui.dart';
import 'dart:async';
import 'base_component.dart';
import '../service/mdt_query.dart';
import '../model/errors.dart';

@Component(
    selector: 'login_comp',
    templateUrl: 'user_login.html',
    useShadowDom: false
)
class LoginComponent extends BaseComponent {
  Modal modal;
  String email="";
  String password="";

  NgRoutingHelper locationService;
  MDTQueryService mdtQueryService;


  String backdrop = 'true';
  //@NgTwoWay('isHttpLoading')

  void login(){
    loginUser(email, password);
  }

  Future loginUser(String email, String password) async {
    var response = null;
    try {
      isHttpLoading = true;
      response = await mdtQueryService.loginUser(email, password);

      if (response["status"] == 200){
        //hide popup
        // mainComp().isUserConnected= true;
        // mainComp().currentUser = response["data"];
        scope.rootScope.context.userLogguedIn(response["data"]);
        modal.close(true);
        //mainComp().hidePopup();
        locationService.router.go('apps',{});
      }else {
        errorMessage = { 'type': 'danger', 'msg': 'Unknown error: $response'};
      }
    } on LoginError catch(e) {
      errorMessage = { 'type': 'danger', 'msg': e.message};
    } on ConnectionError catch(e) {
      errorMessage = { 'type': 'danger', 'msg': e.message};
    } catch(e) {
      errorMessage = { 'type': 'danger', 'msg': 'Unknown error $e'};
    } finally {
      isHttpLoading = false;
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

  LoginComponent(this.locationService,this.mdtQueryService,this.modal){
    print("LoginComponent created: ");
    // mainComp = scope.parentScope.context;
  }
}