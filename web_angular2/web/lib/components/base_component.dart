import 'package:angular2/core.dart';
import '../model/errors.dart';
import '../services/global_service.dart';
import '../model/mdt_model.dart';

class BaseComponent {
  GlobalService get global_service => _global_service;
  GlobalService _global_service;
  var isHttpLoading = false;
  var error = null;
  BaseComponent.withGlobal(GlobalService globalService){
    this._global_service = globalService;
  }
  BaseComponent();

  //utilities functions
  bool canAdministrate(MDTApplication forApp){
    bool displayAdminOption  = global_service.adminOptionsDisplayed;
    if (global_service.connectedUser.isSystemAdmin && displayAdminOption){
      return true;
    }
    var email = global_service.connectedUser.email.toLowerCase();
    var adminFound =  forApp.adminUsers.firstWhere((o) => o.email!=null ? (o.email.toLowerCase() == email) : false, orElse: () => null);

    if (adminFound != null && displayAdminOption){
      return true;
    }
    return false;
  }
}