import 'package:angular/angular.dart';
import 'user_login.dart';
import 'user_register.dart';
import 'account_activation.dart';
import 'users_administration.dart';
import 'user_detail.dart';
import 'account_details.dart';
import 'input_password.dart';
import 'log_console.dart';

class MDTUserModule extends Module {
  MDTUserModule() {
    bind(LoginComponent);
    bind(RegisterComponent);
    bind(AccountActivationComponent);
    bind(UsersAdministration);
    bind(UsersDetail);
    bind(AccountDetailsComponent);
    bind(InputPasswordComponent);
    bind(LogComponent);
  }
}

