import 'package:angular/angular.dart';
import 'package:logging/logging.dart';
import 'package:angular/application_factory.dart';
import 'users_component.dart';
import 'applications_component.dart';
import 'artifacts_component.dart';

void MDTRouteInitializer(Router router, RouteViewFactory views) {
  print("views.configure");
  views.configure({
    'home': ngRoute(
        path: '/home',
        defaultRoute : true,
        view: 'pages/home.html'),
    'app': ngRoute(
        path: '/apps',
        view: 'pages/apps.html',
          mount: {
            'artifacts': ngRoute(
            path: '/:appId/artifacts',
            view: 'pages/artifacts.html')}),
    'users': ngRoute(
        path: '/users',
        view: 'pages/users.html')
  });
}


class MDTAppModule extends Module {
  MDTAppModule() {
    bind(UsersComponent);
    bind(ApplicationsComponent);
    bind(ArtifactsComponent);
    bind(RouteInitializerFn, toValue: MDTRouteInitializer);
    bind(NgRoutingUsePushState, toValue: new NgRoutingUsePushState.value(false));
  }
}

void main() {
  Logger.root..level = Level.FINEST
    ..onRecord.listen((LogRecord r) { print(r.message); });

  print("main");
  applicationFactory()
  .addModule(new MDTAppModule())
  .run();
}