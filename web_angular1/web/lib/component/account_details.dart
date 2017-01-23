import 'package:angular/angular.dart';
import 'package:angular_ui/angular_ui.dart';
import 'dart:core';
import 'dart:async';
import 'base_component.dart';
import '../model/mdt_model.dart';
import '../service/mdt_query.dart';
import 'confirmation_popover.dart';

@Component(
    selector: 'account_details',
    templateUrl: 'account_details.html',
    useShadowDom: false)
class AccountDetailsComponent extends BaseComponent {
  Modal modal;
  String newName ="";
  String newPassword ="";
  String warningMessage = null;
  MDTQueryService _mdtQueryService;
  MDTUser currentUser;
  var userDetailErrorMessage = null;
  List<MDTApplication> administratedApps = new List<MDTApplication>();
  bool get canUpdate => currentUser!=null && ((currentUser.name != newName) || newPassword.length>0);
  AccountDetailsComponent(RouteProvider routeProvider,this._mdtQueryService,this.modal){
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
    currentUser = scope.rootScope.context.currentUser;
    if (currentUser.email == null ){
      userDetailErrorMessage = { 'type': 'danger', 'msg': 'Error loading user account infos'};
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
      errorMessage = { 'type': 'danger', 'msg': 'Error loading profile:${e.toString()}'};
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
      scope.rootScope.context.currentUser = currentUser;
      userDetailErrorMessage = {'type': 'success', 'msg': 'Updated!'};
      resetUser();
    }catch(e){
      userDetailErrorMessage = {'type': 'danger', 'msg': 'Unable to update user: ${e.toString()}'};
    }
    manageWarning(currentUser);
  }

  void remove(MDTApplication app){
    errorMessage = null;
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
      });
  }
}