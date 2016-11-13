import 'package:angular2/core.dart';

@Component(
    selector: 'login_comp',
    templateUrl: 'user_login_component.html')
class UserLoginComponent {
  var isHttpLoading = false;
  var errorMessage = null;
}