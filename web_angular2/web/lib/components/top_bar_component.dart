import 'package:angular2/core.dart';
import '../services/modal_service.dart';
import 'user_login_component.dart';

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

  TopBarComponent(this._modalService){

  }
}