import 'package:angular2/core.dart';

@Component(
    selector: 'register_comp',
    templateUrl: 'user_register_component.html')
class UserRegisterComponent {
  var isHttpLoading = false;
  var errorMessage = null;
}