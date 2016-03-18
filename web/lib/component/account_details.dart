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
  MDTQueryService _mdtQueryService;
  MDTUser currentUser;
  var userDetailErrorMessage = null;
  List<MDTApplication> administratedApps = new List<MDTApplication>();
  bool get canUpdate => currentUser!=null && ((currentUser.name != newName) || newPassword.length>0);
  AccountDetailsComponent(this._mdtQueryService,this.modal){
    loadAccountDetail();
  }
  Future loadAccountDetail () async{
    currentUser = new MDTUser(scope.rootScope.context.currentUser);
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
    userDetailErrorMessage = nil;
  }

  Future update()async{
    userDetailErrorMessage = null;
    try{
      var password = newPassword.length>0 ? newPassword : null;
      var name = currentUser.name != newName? newName : null;
      var newUser = await _mdtQueryService.updateUser(currentUser.email,username:name,password:password);
      currentUser = newUser;
      scope.rootScope.context.currentUser["name"] = currentUser.name;
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