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
  var maxUsersPerPage = 25;
  var hasMore = true;
  List<MDTUser> allUsers = new List<MDTUser>();

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
      var listOfUsers = await _mdtQueryService.listUsers( currentPage, maxUsersPerPage);
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
}