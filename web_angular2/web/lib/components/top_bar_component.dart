import 'package:angular2/core.dart';
import '../commons.dart';

@Component(
    selector: 'top_bar',
    templateUrl: 'top_bar_component.html')
class TopBarComponent {
  bool get isSystemAdmin => _globalService.isConnectedUserAdmin;
  bool get adminOption => _globalService.adminOptionsDisplayed;
  bool get isUserConnected => _globalService.hasConnectedUser;
  final ModalService _modalService;
  final GlobalService _globalService;

  void displayLoginPopup(){
    _modalService.displayLogin();
  }

  void displayRegisterPopup(){
    _modalService.displayRegister();
  }

  TopBarComponent(this._modalService,this._globalService);

  bool get isLoginModal =>  _modalService.isLoginModal;
  bool get isRegisterModal =>  _modalService.isRegisterModal;
}