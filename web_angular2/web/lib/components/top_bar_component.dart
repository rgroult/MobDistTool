import 'package:angular2/core.dart';
import 'dart:async';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';
import '../commons.dart';

@Component(
    selector: 'top_bar',
    directives: const [ROUTER_DIRECTIVES,materialDirectives],
    providers: materialProviders,
    templateUrl: 'top_bar_component.html')
class TopBarComponent implements OnInit{
  bool get isSystemAdmin => _globalService.isConnectedUserAdmin;
  bool get adminOption => _globalService.adminOptionsDisplayed;
  void set adminOption(bool adminOptionsDisplayed) {
    _globalService.adminOptionsDisplayed = adminOptionsDisplayed;
  }
  bool get isUserConnected => _globalService.hasConnectedUser;
  String get currentUsername => _globalService.connectedUser.name;
  final ModalService _modalService;
  final GlobalService _globalService;

  void displayLoginPopup(){
    _modalService.displayLogin();
  }

  void displayRegisterPopup(){
    _modalService.displayRegister();
  }


  void logout(){

  }

  TopBarComponent(this._modalService,this._globalService);

  bool get isLoginModal =>  _modalService.isLoginModal;
  bool get isRegisterModal =>  _modalService.isRegisterModal;
}