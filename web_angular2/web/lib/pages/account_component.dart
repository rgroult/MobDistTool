import 'dart:async';
import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import '../commons.dart';

@Component(
    selector: 'account_comp',
    templateUrl: 'account_component.html',
    directives: const [materialDirectives,ErrorComponent],
    providers: materialProviders,
    )
class AccountComponent extends BaseComponent implements OnInit {
 // Modal modal;
  String newName ="";
  String newPassword ="";
  String warningMessage = null;
  MDTQueryService _mdtQueryService;
  MDTUser currentUser;
  var userDetailErrorMessage = null;
  List<MDTApplication> administratedApps = new List<MDTApplication>();
  bool get canUpdate => currentUser!=null && ((currentUser.name != newName) || newPassword.length>0);
  AccountComponent(this._mdtQueryService,GlobalService globalService) : super.withGlobal(globalService);

  void ngOnInit(){
    loadAccountDetail();
  }

  void manageWarning(MDTUser user){
    var warnings = {
      "passwordStrengthFailed":"Your password strength does not meet miniumum server requirement.\nPlease update it !"
    };
    warningMessage = null;
    if (user.passwordStrengthFailed == true){
      warningMessage = warnings["passwordStrengthFailed"];
    }
  }
  Future loadAccountDetail () async{
    //var mapUser = scope.rootScope.context.currentUser;
    currentUser = global_service.connectedUser;
    if (currentUser.email == null ){
      userDetailErrorMessage = new UIError("Error loading user account infos","",ErrorType.ERROR);
      return;
    }
    isHttpLoading = true;
    //var userEmail = currentUser.email.toLowerCase();
    newName = currentUser.name;
    try {
      var myprofile = await _mdtQueryService.myProfile();
      //var me = myprofile["user"];
      administratedApps.addAll(myprofile["apps"]);
    }catch(e){
      error = new UIError("Error loading profile","$e",ErrorType.ERROR);
    } finally {
      isHttpLoading = false;
    }
    manageWarning(currentUser);
  }

  void resetUser(){
    newPassword = "";
    newName = currentUser.name;
  }

  void hideUserErrorMessage(){
    userDetailErrorMessage = null;
  }

  Future update()async{
    userDetailErrorMessage = null;
    try{
      var password = newPassword.length>0 ? newPassword : null;
      var name = currentUser.name != newName? newName : null;
      var newUser = await _mdtQueryService.updateUser(currentUser.email,username:name,password:password);
      //password update ?
      if (newPassword.length == 0) {
        newUser.passwordStrengthFailed = currentUser.passwordStrengthFailed;
      }
      currentUser = newUser;
      //update user
      global_service.connectedUser = currentUser;
      userDetailErrorMessage = new UIError("Updated","",ErrorType.SUCCESS);
     // userDetailErrorMessage = {'type': 'success', 'msg': 'Updated!'};
      resetUser();
    }catch(e){
      userDetailErrorMessage = new UIError("Unable to update user","$e",ErrorType.ERROR);
      //userDetailErrorMessage = {'type': 'danger', 'msg': 'Unable to update user: ${e.toString()}'};
    }
    manageWarning(currentUser);
  }

  void remove(MDTApplication app){
    error = null;
    /*
    var modalInstance = ConfirmationComponent.createConfirmation(modal,scope,"Are you sure to remove your administration rights from ${app.name} ?","");
    modalInstance.result
      ..then((v) {
        if (v == true){
          try {
            isHttpLoading = true;
            _mdtQueryService.deleteAdministrator(app,currentUser.email).then((v){
              administratedApps.remove(app);
            }).catchError((e) {
              errorMessage = { 'type': 'danger', 'msg': '$e'};
            });
          }catch(e) {
            errorMessage = { 'type': 'danger', 'msg': '$e'};
          } finally {
            isHttpLoading = false;
          }
        }
      }); */
  }
}