import 'package:angular2/core.dart';
import 'dart:async';
import '../services/modal_service.dart';
import 'user_login_component.dart';
import 'user_register_component.dart';
import 'edit_application_component.dart';
import 'dart:html';
import '../model/mdt_model.dart';


enum ModalRequired { NONE, LOGIN , REGISTER,EDIT_APP }

@Component(
    selector: 'modal_comp',
    directives: const [UserLoginComponent,UserRegisterComponent,EditAppComponent],
    templateUrl: 'modals_components.html')
class ModalsComponent implements OnInit {
  final ModalService _modalService;
  ModalsComponent(this._modalService);
  Map<String,dynamic> parameters;

  void ngOnInit() {
    _modalService.registerComponent(this);

    print("self ${querySelector("#allModals")}");
  }

  void displayModal(ModalRequired mode){
    parameters = null;
    _currentModal = mode;
    if (_currentModal == ModalRequired.NONE){
      //call hide button
      querySelector("#allModalsCloseButton").click();
    }
    //print("change modal mode to $_currentModal");
  }

  void displayApplicationEdition(Map<String,dynamic>  params /*bool isCreation, {MDTApplication app}*/) {
    displayModal(ModalRequired.EDIT_APP);
    parameters = params;
    new Future.delayed(new Duration(milliseconds: 100)).then( (content) {

    });
   // parameterValue = isCreation;

    //await new Future.delayed(new Duration(milliseconds: 100));

  }

  var _currentModal = ModalRequired.NONE;

  bool get isLoginModal =>  _currentModal == ModalRequired.LOGIN;
  bool get isRegisterModal =>  _currentModal == ModalRequired.REGISTER;
  bool get isDisplayed => !(_currentModal == ModalRequired.NONE);
  bool get isEditAppModal => _currentModal == ModalRequired.EDIT_APP;

  var isHttpLoading = false;
  var errorMessage = null;
}