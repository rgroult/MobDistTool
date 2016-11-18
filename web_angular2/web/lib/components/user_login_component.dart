import 'package:angular2/core.dart';
import '../commons.dart';
import 'dart:async';

@Component(
    selector: 'login_comp',
    directives: const [ErrorComponent],
    templateUrl: 'user_login_component.html')
class UserLoginComponent extends BaseComponent{
  MDTQueryService _mdtQueryService;
  ModalService _modalService;
  String email="";
  String password="";

  UserLoginComponent(this._mdtQueryService,this._modalService, GlobalService globalService) : super.withGlobal(globalService);

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
      global_service.updateCurrentUser(connectedUser);
      _modalService.hideModal();
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