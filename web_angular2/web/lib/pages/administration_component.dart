import 'dart:async';
import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import '../commons.dart';
import '../components/log_console_component.dart';
import '../components/users_administration_component.dart';

@Component(
    selector: 'administration_comp',
    templateUrl: 'administration_component.html',
    directives: const [materialDirectives,ErrorComponent,LogConsoleComponent,UsersAdministrationComponent],
    providers: materialProviders,
    )
class AdministrationComponent {

}