import 'package:angular/angular.dart';
import 'user_login.dart';
import 'user_register.dart';

class MDTUserModule extends Module {
  MDTUserModule() {
    bind(LoginComponent);
    bind(RegisterComponent);
  }
}

