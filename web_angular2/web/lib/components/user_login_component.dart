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
  var loginForm;

  UserLoginComponent(this._mdtQueryService,this._modalService, GlobalService globalService) : super.withGlobal(globalService);

  void login(){
    print("Login");
    loginUser(email,password);
  }

  void displayRegister(){
    _modalService.displayRegister();
  }

  Future loginUser(String email, String password) async {
    var connectedUser = null;
    error = null;
    try {
      isHttpLoading = true;
      connectedUser = await _mdtQueryService.loginUser(email, password);
      global_service.updateCurrentUser(connectedUser);
      _modalService.hideModal();
      global_service.goToApps();
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