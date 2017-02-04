import 'dart:async';
import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import '../commons.dart';
import '../services/mdt_query.dart';

@Component(
    selector: '[user_detail]',
    directives: const [materialDirectives],
    providers: materialProviders,
    templateUrl: 'user_detail_component.html'
)
class UsersDetailComponent implements OnInit {
 @Input()
  MDTUser user;
 @Output()
 var userDeleted = new EventEmitter();

  //UsersAdministration _parent;
  MDTQueryService _mdtQueryService;

  bool isActivated = false;
  bool isAdmin = false;
  String password = "";
  String name = "";

 UsersDetailComponent(this._mdtQueryService){
    print("UsersDetail created");
  }

  void ngOnInit() {
      name = user.name;
      isActivated = user.isActivated;
      isAdmin = user.isSystemAdmin;
  }

  void resetUser(){
    password = "";
    name = user.name;
    isActivated = user.isActivated;
    isAdmin = user.isSystemAdmin;
  }

  bool get canUpdate => (user.name != name) || (user.isActivated != isActivated) || (user.isSystemAdmin != isAdmin) || password.length>0;


  Future delete() async{
    try{
      //await _mdtQueryService.deleteUser(user.email);
      userDeleted.emit(user);
      //_parent.userDeleted(user);
    }catch(e){
      //_parent.errorMessage = {'type': 'danger', 'msg': 'Unable to delete user: ${e.toString()}'};
    }
  }

  Future update()async{
    try{
      var newPassword = password.length>0 ? password : null;
      var newName = user.name != name? name : null;
      var activated = user.isActivated != isActivated ? isActivated : null;
      var sysadmin = user.isSystemAdmin != isAdmin ? isAdmin : null;
      var newUser = await _mdtQueryService.updateUser(user.email,username:newName,password:newPassword,isAdmin:sysadmin,isActivated:activated);
      user = newUser;

      resetUser();
    }catch(e){
      //_parent.errorMessage = {'type': 'danger', 'msg': 'Unable to update user: ${e.toString()}'};
    }
  }
/*
  @override
  void onShadowRoot(ShadowRoot shadowRoot) {
    initComponent();
    // get content for table cells (ignore <content> and <style> tags)
    var templateElements = new List<Element>.from(shadowRoot.children.where((e) => !(e is StyleElement) && !(e is ContentElement)));

    // the table cells need to be put into the <content> element to become childs of the table row
    ContentElement ce = shadowRoot.querySelector('content');

    templateElements.forEach((span) {
      // remove from old place before adding to new parent
      span.remove();

      // get the content of a table cell (the future <td> content)
      var cellContent = new List<Node>.from(span.childNodes);

      // remove cell content from span before adding to the table cell
      cellContent.forEach((cc) => cc.remove());
      var td = new TableCellElement();

      cellContent.forEach((cc) => td.append(cc));

      ce.append(td);
    });
  }
*/

}