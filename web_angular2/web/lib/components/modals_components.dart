import 'package:angular2/core.dart';
import '../services/modal_service.dart';
import 'user_login_component.dart';
import 'user_register_component.dart';
import 'dart:html';

enum ModalRequired { NONE, LOGIN , REGISTER }

@Component(
    selector: 'modal_comp',
    directives: const [UserLoginComponent,UserRegisterComponent],
    templateUrl: 'modals_components.html')
class ModalsComponent implements OnInit {
  final ModalService _modalService;
  ModalsComponent(this._modalService);

  void ngOnInit() {
    _modalService.registerComponent(this);
  }

  void displayModal(ModalRequired mode){
    _currentModal = mode;
    if (_currentModal == ModalRequired.NONE){
      //call hide button
      querySelector("#allModalsCloseButton").click();
    }
  }
  var _currentModal = ModalRequired.NONE;

  bool get isLoginModal =>  _currentModal == ModalRequired.LOGIN;
  bool get isRegisterModal =>  _currentModal == ModalRequired.REGISTER;
  bool get isDisplayed => !(_currentModal == ModalRequired.NONE);

  var isHttpLoading = false;
  var errorMessage = null;
}