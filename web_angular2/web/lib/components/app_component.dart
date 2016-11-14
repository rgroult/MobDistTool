import 'package:angular2/core.dart';
import 'top_bar_component.dart';
import 'bottom_bar_component.dart';
import 'route_bar_component.dart';
import '../services/modal_service.dart';
import 'user_login_component.dart';
import 'modals_components.dart';

@Component(
    selector: 'mdt_comp',
    directives: const [BottomBarComponentComponent,RouteBarComponentComponent,TopBarComponent,ModalsComponent],
    providers: const [ModalService],
    templateUrl: 'app_component.html')
class AppComponent {


}