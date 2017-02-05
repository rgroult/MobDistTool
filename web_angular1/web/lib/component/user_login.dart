import 'package:angular/angular.dart';
import 'package:angular_ui/angular_ui.dart';
import 'dart:async';
import 'base_component.dart';
import '../service/mdt_query.dart';
import '../model/errors.dart';
import '../model/mdt_model.dart';
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
        var userData = response["data"];
        scope.rootScope.context.userLogguedIn(new MDTUser(userData));
        modal.close(true);
        //mainComp().hidePopup();
        if (userData["passwordStrengthFailed"] == true){
          //go to settings with warning
          locationService.router.go('account',{});
        }else {
          //go to apps
          locationService.router.go('apps',{});
        }

      }else {
        errorMessage = { 'type': 'danger', 'msg': 'Error: $response'};
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
  }

  LoginComponent(this.locationService,this.mdtQueryService,this.modal){
    print("LoginComponent created: ");
    // mainComp = scope.parentScope.context;
  }
}