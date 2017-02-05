import 'package:angular2/core.dart';
import 'dart:html';
import  '../components/modals_components.dart';
import '../model/mdt_model.dart';
import '../components/edit_application_component.dart';
import '../components/add_artifact_component.dart';

@Injectable()
class ModalService {
  ModalsComponent _modalComponent;

  void registerComponent(ModalsComponent comp){
    _modalComponent = comp;
  }

  void displayLogin(){
    _modalComponent.displayModal(ModalRequired.LOGIN,additionalsParameters:{});
  }

  void displayCreateApplication(EditAppComponentAware caller){
   // ar isModeEdition = false
    //application
    _modalComponent.displayApplicationEdition({'isModeEdition':false,'delegate':caller});
  }

  void displayEditApplication(MDTApplication app,EditAppComponentAware caller){
    _modalComponent.displayApplicationEdition({'isModeEdition':true,'application':app,'delegate':caller});
  }

  void displayAddArtifact(MDTApplication app,AddArtifactComponentAware caller){
    _modalComponent.displayModal(ModalRequired.ADD_ARTIFACT,additionalsParameters:{'application':app,'delegate':caller});
  }

  void displayRegister(){
    _modalComponent.displayModal(ModalRequired.REGISTER,additionalsParameters:{});
  }

  void displayQrCode(MDTArtifact artifact,String title){
    _modalComponent.displayModal(ModalRequired.QR_CODE,additionalsParameters:{'artifact':artifact,'title':title});
  }

  void hideModal(){
    _modalComponent.displayModal(ModalRequired.NONE);
  }

  ModalService();

  bool get isLoginModal =>  _modalComponent.isLoginModal;
  bool get isRegisterModal =>  _modalComponent.isRegisterModal;

}