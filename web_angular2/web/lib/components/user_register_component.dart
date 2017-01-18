import 'package:angular2/core.dart';
import 'dart:async';
import 'package:validator/validator.dart';
import '../commons.dart';
import 'dart:convert';

@Component(
    selector: 'register_comp',
    directives: const [ErrorComponent],
    templateUrl: 'user_register_component.html')
class UserRegisterComponent extends BaseComponent{
  MDTQueryService _mdtQueryService;
  ModalService _modalService;
  String email="";
  String password="";
  String username ="";
  var registerForm;

  UserRegisterComponent(this._mdtQueryService,this._modalService, GlobalService globalService) : super.withGlobal(globalService);

  void register() {
    registerUser(username,email,password);
  }

  void displayLogin(){
    _modalService.displayLogin();
  }

  bool _checkParameters(String username,String email, String password){
    if (isEmail(email) == false) {
      error = new UIError('Invalid email format',"",ErrorType.ERROR);
      return false;
    }
    if (username == null){
      error = new UIError('user name must not be empty',"",ErrorType.ERROR);
      return false;
    }
    if (password == null){
      error = new UIError('password must not be empty',"",ErrorType.ERROR);
      return false;
    }
    return true;
  }

  Future registerUser(String username,String email, String password) async {
    error = null;
    var response = null;
    if (_checkParameters(username,email,password) == false){
      return;
    }
    try {
      isHttpLoading = true;
      response = await _mdtQueryService.registerUser(username,email,password);
      if (response["status"] == 200){
        var responseData = response["data"] ?? {};
        error = new UIError('Registration completed',"${responseData['email']}. ${responseData['message'] ?? ''}",ErrorType.SUCCESS);
      }else {
        error = new UIError(RegisterError.errorCode,'Unknown error: $response',ErrorType.ERROR);
      }
    } on RegisterError catch(e) {
      error = new UIError(RegisterError.errorCode,e.message,ErrorType.ERROR);
    } catch(e) {
      error = new UIError(RegisterError.errorCode,'Unknown error: $e',ErrorType.ERROR);
    } finally {
      isHttpLoading = false;
    }
  }
}