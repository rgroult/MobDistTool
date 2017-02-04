import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';
import '../all_angular_components.dart';

@Component(
    selector: 'mdt_comp',
    directives: const [ROUTER_DIRECTIVES,materialDirectives,MDT_DIRECTIVES],
    providers: const [materialProviders,MDT_PROVIDERS],
    templateUrl: 'app_component.html')
@RouteConfig(const [
  const Route(path: '/home', name: 'Home', component: HomeComponent, useAsDefault: true),
  const Route(path: 'activation', name: 'Activation', component: ActivationComponent),
  const Route(path: '/apps', name: 'Apps', component: ApplicationListComponent),
  const Route(path: '/account', name: 'Account', component: AccountComponent),
  const Route(path: '/administration', name: 'Administration', component: AdministrationComponent),
  const Route(path: '/versions/:appid', name: 'Versions', component: ApplicationDetailComponent)
])
class AppComponent {

}
// /web/index.html#/activation?token='