import 'dart:async';
import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import '../commons.dart';
import '../services/mdt_query.dart';
import 'user_detail_component.dart';

@Component(
    selector: 'users_administration',
    directives: const [ErrorComponent,materialDirectives,UsersDetailComponent],
    templateUrl: 'users_administration_component.html'
)
class UsersAdministrationComponent  extends BaseComponent implements OnInit {
  MDTQueryService _mdtQueryService;
  var currentPage = 1;
  double maxUsersPerPage = 25.toDouble();
  var hasMore = true;
  List<MDTUser> allUsers = new List<MDTUser>();
  var orderBy = "email";
  var ascending = true;

  UsersAdministrationComponent(this._mdtQueryService);

  void ngOnInit() {
    reload();
  }


  MDTUser userByEmail(String email){
    return allUsers.firstWhere((o) => o.email == email);
  }

  void userDeleted(MDTUser user){
      allUsers.remove(user);
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
      var listOfUsers = await _mdtQueryService.listUsers( currentPage, maxUsersPerPage.round(),orderBy,ascending);
      allUsers.clear();
      allUsers.addAll(listOfUsers.users);
      hasMore = listOfUsers.hasMore;
      currentPage = listOfUsers.pageIndex;
     // print("display ${allUsers.length} users on page ${currentPage}, hasMore: $hasMore");
    } catch (e) {
      //print("Error on retrieving users");
      error = new UIError("Error while loading Users","$e",ErrorType.ERROR);
    } finally {
      isHttpLoading = false;
    }
  }

  Future deleteUser(MDTUser user) async{
    try{
      await _mdtQueryService.deleteUser(user.email);
      userDeleted(user);
    }catch(e){
      error = new UIError("Unable to delete user ${user.email}",e.toString(),ErrorType.ERROR);
      //_parent.errorMessage = {'type': 'danger', 'msg': 'Unable to delete user: ${e.toString()}'};
    }

  }

  void sortUsers(String newOrderBy){
      if (orderBy == newOrderBy){
        ascending = !ascending;
      }else {
        orderBy = newOrderBy;
        ascending = true;
      }
      reload();
  }

  String getOrderIcon(String testOrderBy){
    if (testOrderBy == orderBy){
      return ascending ? "keyboard_arrow_up" : "keyboard_arrow_down";
    }
    return "";
  }
}