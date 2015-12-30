import 'package:angular/angular.dart';

void MDTRouteInitializer(Router router, RouteViewFactory views) {
  print("views.configure");
  views.configure({
    'home': ngRoute(
        path: '/home',
        defaultRoute : true,
        view: 'pages/home.html'),
    'apps': ngRoute(
        path: '/apps',
        viewHtml: '<application_list></application_list>',
        //view: 'pages/apps_list.html',
        mount: {
          'artifacts': ngRoute(
              path: '/:appId/artifacts',
              viewHtml: '<application_detail></application_detail>',
              enter: (RouteEnterEvent e) =>
                print(e)
          //view: 'pages/artifacts_list.html'
          )}),
    'users': ngRoute(
        path: '/users',
        view: 'pages/users.html')
  });
}