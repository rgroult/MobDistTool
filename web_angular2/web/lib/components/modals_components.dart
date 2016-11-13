import 'package:angular2/core.dart';

enum ModalRequired { NONE, LOGIN , REGISTER }

@Component(
    selector: 'modal_comp',
    templateUrl: 'modals_components.html')
class ModalsComponent {
  var _currentModal = ModalRequired.NONE;

  bool get isLoginModal =>  _currentModal == ModalRequired.LOGIN;
  bool get isRegisterModal =>  _currentModal == ModalRequired.LOGIN;
  bool get isDisplayed => !(_currentModal == ModalRequired.NONE);

  var isHttpLoading = false;
  var errorMessage = null;
}