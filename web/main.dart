import 'package:angular/angular.dart';
import 'package:logging/logging.dart';
import 'package:angular/application_factory.dart';

void MDTRouteInitializer(Router router, RouteViewFactory views) {
  print("views.configure");
  views.configure({
    'home': ngRoute(
        path: '/home',
        defaultRoute : true,
        view: 'pages/home.html'),
    'app': ngRoute(
        path: '/app/:appId',
        view: 'pages/apps.html',
          mount: {
            'artifacts': ngRoute(
            path: '/artifacts',
            view: 'pages/artifacts.html')}),
    'users': ngRoute(
        path: '/users',
        view: 'pages/users.html')
  });
}


class MDTAppModule extends Module {
  MDTAppModule() {
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