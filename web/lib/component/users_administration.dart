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
    reload();
    /*
    var user1 = new MDTUser({})
        ..email = 'test@toto.com'
        ..name = 'user1'
        ..isActivated = false
        ..isSystemAdmin = true;
    var user2 = new MDTUser({})
      ..email = 'test2@toto.com'
      ..name = 'user2'
      ..isActivated = true
      ..isSystemAdmin = true;


    allUsers.add(user1);
    allUsers.add(user2);*/
  }


  MDTUser userByEmail(String email){
    return allUsers.firstWhere((o) => o.email == email);
  }

  void userDeleted(MDTUser user){

  }

  void next(){
    if (hasMore) {
      currentPage = currentPage + 1;
      loadNextUsersPage();
    }
  }

  void previous(){
      if (currentPage>1) {
        currentPage = currentPage - 1;
        loadNextUsersPage();
      }
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
      print("display ${allUsers.length} users on page ${currentPage}, hasMore: $hasMore");
    } catch (e) {
      errorMessage =
      { 'type': 'danger', 'msg': 'Error while loading Users:${e.toString()}'};
    } finally {
      isHttpLoading = false;
    }
  }
}