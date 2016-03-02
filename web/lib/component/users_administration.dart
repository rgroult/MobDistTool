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
  var currentPage = 1;
  var maxUsersPerPage = 25;
  var hasMore = true;
  List<MDTUser> allUsers = new List<MDTUser>();

  UsersAdministration(this.mdtQueryService) {

  }

  MDTUser userByEmail(String email){
    return allUsers.firstWhere((o) => o.email == email);
  }

  void reload() {
    currentPage = 1;
    loadNextUsersPage();
  }

  Future loadNextUsersPage() async {
    try {
      isHttpLoading = true;
      var listOfUsers = await mdtQueryService.listUsers(
          currentPage, maxUsersPerPage);
      allUsers.clear();
      allUsers.addAll(listOfUsers.users);
      hasMore = listOfUsers.hasMore;
      currentPage = listOfUsers.pageIndex;
      print("display ${allUsers.length} users on page ${currentPage}");
    } catch (e) {
      errorMessage =
      { 'type': 'danger', 'msg': 'Error while loading Users:${e.toString()}'};
    } finally {
      isHttpLoading = false;
    }
  }
}