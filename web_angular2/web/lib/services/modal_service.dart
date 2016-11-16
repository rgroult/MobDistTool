import 'package:angular2/core.dart';
import 'dart:html';
import  '../components/modals_components.dart';

@Injectable()
class ModalService {
  ModalsComponent _modalComponent;

  void registerComponent(ModalsComponent comp){
    _modalComponent = comp;
  }

  void displayLogin(){
    _modalComponent.displayModal(ModalRequired.LOGIN);
  }

  void displayRegister(){
    _modalComponent.displayModal(ModalRequired.REGISTER);
  }

  void hideModal(){
    _modalComponent.displayModal(ModalRequired.NONE);
  }

  ModalService();

  bool get isLoginModal =>  _modalComponent.isLoginModal;
  bool get isRegisterModal =>  _modalComponent.isRegisterModal;
}