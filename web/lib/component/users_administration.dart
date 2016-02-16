import 'package:angular/angular.dart';
import 'package:angular_ui/angular_ui.dart';
import 'dart:async';
import 'base_component.dart';
import '../service/mdt_query.dart';
import '../model/mdt_model.dart';
import '../model/errors.dart';

@Component(
    selector: 'users_administration',
    templateUrl: 'users_administration.html',
    useShadowDom: false
)
class UsersAdministration extends BaseComponent {
  MDTQueryService mdtQueryService;
  List<MDTUser> allUsers = new List<MDTUser>();
  UsersAdministration(this.mdtQueryService){

  }
}