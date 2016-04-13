import 'package:angular/angular.dart';
import 'package:angular_ui/angular_ui.dart';
import 'dart:core';
import 'dart:async';
import 'dart:html';
import 'base_component.dart';
import 'application_detail.dart';
import '../model/mdt_model.dart';
import '../model/errors.dart';
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
   /* var warning = routeProvider.parameters['warning'];
    if (warning != null){
      manageWarning(warning);
    }*/
    loadAccountDetail();
  }
  /*
  void manageWarning(String warning){
    var warnings = {
      "passwordStrengthFailed":"Your password strength does not meet miniumum server requirement. Please update it !"
    };
    warningMessage = warnings[warning];
  }*/
  Future loadAccountDetail () async{
    var mapUser = scope.rootScope.context.currentUser;
    currentUser = new MDTUser(mapUser);
    if (mapUser["passwordStrengthFailed"] == true){
      warningMessage = "Your password strength does not meet miniumum server requirement.\nPlease update it !";
    }
    if (currentUser.email == null ){
      userDetailErrorMessage = { 'type': 'danger', 'msg': 'Error loading user account infos'};
      return;
    }
    isHttpLoading = true;
    var userEmail = currentUser.email.toLowerCase();
    newName = currentUser.name;
    try {
      var apps= await _mdtQueryService.getApplications();
      administratedApps.clear();
      //filter by apps which contains user as admin
      var appFiltered = apps.where((tmpApp) => tmpApp.adminUsers.firstWhere((user) => user.email!=null ? (user.email.toLowerCase() == userEmail) : false, orElse: () => null ) != null);
      administratedApps.addAll(appFiltered);
    }catch(e){
      errorMessage = { 'type': 'danger', 'msg': 'Error loading Administrated Apps:${e.toString()}'};
    } finally {
      isHttpLoading = false;
    }
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
      currentUser = newUser;
      Map userInfo =  scope.rootScope.context.currentUser;
      //change name
      userInfo["name"] = currentUser.name;
      //password updated
      if (newPassword.length>0){
        warningMessage = null;
        userInfo.remove("passwordStrengthFailed");
      }
      userDetailErrorMessage = {'type': 'success', 'msg': 'Updated!'};
      resetUser();
    }catch(e){
      userDetailErrorMessage = {'type': 'danger', 'msg': 'Unable to update user: ${e.toString()}'};
    }
  }

  Future remove(MDTApplication app){
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