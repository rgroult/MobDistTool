import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import 'top_bar_component.dart';
import 'bottom_bar_component.dart';
import 'route_bar_component.dart';
import '../services/modal_service.dart';
import 'user_login_component.dart';
import 'modals_components.dart';
import '../services/mdt_query.dart';

@Component(
    selector: 'mdt_comp',
    directives: const [materialDirectives,BottomBarComponentComponent,RouteBarComponentComponent,TopBarComponent,ModalsComponent],
    providers: const [materialProviders,ModalService,MDTQueryService],
    templateUrl: 'app_component.html')
class AppComponent {


}