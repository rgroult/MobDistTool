import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';
import 'top_bar_component.dart';
import 'bottom_bar_component.dart';
import 'route_bar_component.dart';
import '../services/modal_service.dart';
import '../services/global_service.dart';
import 'user_login_component.dart';
import 'modals_components.dart';
import '../services/mdt_query.dart';
import '../pages/home_component.dart';

@Component(
    selector: 'mdt_comp',
    directives: const [ROUTER_DIRECTIVES,materialDirectives,BottomBarComponentComponent,RouteBarComponentComponent,TopBarComponent,ModalsComponent,
    HomeComponent],
    providers: const [materialProviders,ModalService,GlobalService,MDTQueryService,ROUTER_PROVIDERS],
    templateUrl: 'app_component.html')
@RouteConfig(const [
  const Route(path: '/home', name: 'Home', component: HomeComponent, useAsDefault: true)
])
class AppComponent {

}