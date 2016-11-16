import 'package:angular2/core.dart';
import '../services/modal_service.dart';

@Component(
    selector: 'top_bar',
    templateUrl: 'top_bar_component.html')
class TopBarComponent {
  bool isSystemAdmin = true;
  bool adminOption = true;
  bool isUserConnected = false;
  final ModalService _modalService;

  void displayLoginPopup(){
    _modalService.displayLogin();
  }

  void displayRegisterPopup(){
    _modalService.displayRegister();
  }

  TopBarComponent(this._modalService);

  bool get isLoginModal =>  _modalService.isLoginModal;
  bool get isRegisterModal =>  _modalService.isRegisterModal;
}