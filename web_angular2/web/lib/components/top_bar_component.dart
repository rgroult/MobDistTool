import 'package:angular2/core.dart';
import '../services/modal_service.dart';
import 'user_login_component.dart';

enum ModalRequired { NONE, LOGIN , REGISTER }

@Component(
    selector: 'top_bar',
    providers: const [ModalService],
    directives : const [UserLoginComponent],
    templateUrl: 'top_bar_component.html')
class TopBarComponent {
  bool isSystemAdmin = true;
  bool adminOption = true;
  bool isUserConnected = false;
  final ModalService _modalService;
  ModalRequired currentModal = ModalRequired.NONE;

  bool get  isLoginModal =>  currentModal == ModalRequired.LOGIN;

  void displayLoginPopup(){
    currentModal = ModalRequired.LOGIN;
      _modalService.createModal("<login_comp></login_comp>");
  }

  TopBarComponent(this._modalService){

  }
}