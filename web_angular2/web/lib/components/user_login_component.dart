import 'package:angular2/core.dart';
import 'dart:async';
import '../services/mdt_query.dart';
import '../services/modal_service.dart';
import '../model/errors.dart';
import 'base_component.dart';
import 'error_component.dart';

@Component(
    selector: 'login_comp',
    directives: const [ErrorComponent],
    templateUrl: 'user_login_component.html')
class UserLoginComponent extends BaseComponent{
  MDTQueryService _mdtQueryService;
  ModalService _modalService;
  String email="";
  String password="";

  UserLoginComponent(this._mdtQueryService,this._modalService);

  void login(){
    print("Login");
    loginUser(email,password);
  }

  Future loginUser(String email, String password) async {
    var connectedUser = null;
    error = null;
    try {
      isHttpLoading = true;
      connectedUser = await _mdtQueryService.loginUser(email, password);
/*
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
      }*/
    } on LoginError catch(e) {
      error = new UIError(LoginError.errorCode,e.message,ErrorType.ERROR);
      //errorMessage = { 'type': 'danger', 'msg': e.message};
    } on ConnectionError catch(e) {
      error = new UIError(ConnectionError.errorCode,e.message,ErrorType.ERROR);
      //errorMessage = { 'type': 'danger', 'msg': e.message};
    } catch(e) {
      error = new UIError("UNKNOWN ERROR","Unknown error $e",ErrorType.ERROR);
      //errorMessage = { 'type': 'danger', 'msg': 'Unknown error $e'};
    } finally {
      isHttpLoading = false;
    }



  }
}