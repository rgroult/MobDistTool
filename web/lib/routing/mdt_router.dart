import 'package:angular/angular.dart';

void MDTRouteInitializer(Router router, RouteViewFactory views) {
  print("views.configure");
  views.configure({
    'home': ngRoute(
        path: '/home',
        defaultRoute : true,
        view: 'pages/home.html',
        enter: (RouteEnterEvent e) => _enterRoute(e),
        preLeave: (RoutePreLeaveEvent e) =>  preLeaveRoute(e)),
    'apps': ngRoute(
        path: '/apps',
        viewHtml: '<application_list></application_list>',
        enter: (RouteEnterEvent e) => _enterRoute(e),
        preLeave: (RoutePreLeaveEvent e) =>  preLeaveRoute(e),
        //view: 'pages/apps_list.html',
        mount: {
          'artifacts': ngRoute(
              path: '/:appId/artifacts',
              viewHtml: '<application_detail></application_detail>',
              enter: (RouteEnterEvent e) => _enterRoute(e),
              preLeave: (RoutePreLeaveEvent e) =>  preLeaveRoute(e)
          //view: 'pages/artifacts_list.html'
          )}),
    'users': ngRoute(
        path: '/users',
        view: 'pages/users.html')
  });
}

void _enterRoute(RouteEnterEvent e){
  //this.enterRoute("Home","/home",0);
  print("Enter route : ${e.path}");
}

void preLeaveRoute(RoutePreLeaveEvent e){
  print("PreLeave route : ${e.path}");
}