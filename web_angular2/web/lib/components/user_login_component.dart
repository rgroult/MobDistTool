import 'package:angular2/core.dart';
import '../services/mdt_query.dart';
import '../services/modal_service.dart';

@Component(
    selector: 'login_comp',
    templateUrl: 'user_login_component.html')
class UserLoginComponent {
  MDTQueryService _mdtQueryService;
  ModalService _modalService;
  String email="";
  String password="";
  var isHttpLoading = false;
  var errorMessage = null;

  UserLoginComponent(this._mdtQueryService,this._modalService);

  void login(){
    print("Login");
    loginUser(email,password);
  }

  Future loginUser(String email, String password) async {
    var response = null;
    try {
      isHttpLoading = true;
      response = await _mdtQueryService.loginUser(email, password);

      if (response["status"] == 200){
        //hide popup
        // mainComp().isUserConnected= true;
        // mainComp().currentUser = response["data"];
     /*   var userData = response["data"];
        scope.rootScope.context.userLogguedIn(new MDTUser(userData));
        modal.close(true);
        //mainComp().hidePopup();
        if (userData["passwordStrengthFailed"] == true){
          //go to settings with warning
          locationService.router.go('account',{});
        }else {
          //go to apps
          locationService.router.go('apps',{});
        }*/

      }else {
        errorMessage = { 'type': 'danger', 'msg': 'Error: $response'};
      }
    } on LoginError catch(e) {
      errorMessage = { 'type': 'danger', 'msg': e.message};
    } on ConnectionError catch(e) {
      errorMessage = { 'type': 'danger', 'msg': e.message};
    } catch(e) {
      errorMessage = { 'type': 'danger', 'msg': 'Unknown error $e'};
    } finally {
      isHttpLoading = false;
    }
  }
}