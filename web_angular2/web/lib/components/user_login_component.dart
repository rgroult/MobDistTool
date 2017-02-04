import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import 'dart:async';
import 'dart:html';
import '../commons.dart';

@Component(
    selector: 'login_comp',
    directives: const [ErrorComponent,materialDirectives],
    providers: materialProviders,
    templateUrl: 'user_login_component.html')
class UserLoginComponent extends BaseComponent{
  MDTQueryService _mdtQueryService;
  ModalService _modalService;
  String email="";
  String password="";

  @Input()
  void set parameters(Map<String,dynamic> params) {
    email="";
    password="";
    new Future.delayed(new Duration(milliseconds: 1000)).then( (content) {
      querySelector("#EmailInputField").focus();
    });
   //
  }

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