import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'dart:async';

@Component(
    selector: 'route_bar',
    directives: const [ROUTER_DIRECTIVES],
    templateUrl: 'route_bar_component.html')
class RouteBarComponent implements OnInit{
  final Router _router;
  RouteBarComponent(this._router);
  var routeHistory = [];
  //var routeHistory = [{"path": "TO DO PATH 1", "name":"TO DO NAME1"},{"path": "TO DO PATH 2", "name":"TO DO NAME2"}];
  Future ngOnInit() async {
    _router.subscribe((change) {
      //print ("router change $change");
      this.handleUrlChange(change);
    });
  }

  List<String> routerLink(String routeName, Map<String,String> params){
    if ( params != null ){
      return [routeName,params];
    }
    return [routeName];
  }
  Future handleUrlChange(String url) async {
    var instruction = await _router.recognize(url);
    print ("router instrction $instruction");
    var routeName = instruction.component.routeName;
    routeHistory.clear();
    routeHistory.add({"name": "Home", "displayname":"Home"});
    //ugly swith , should found a better way
    switch (routeName){
      case "Home":
        //add applications
        routeHistory.add({"name": "Apps", "displayname":"Applications"});
        break;
      case "Apps":
        routeHistory.add({"name": "Apps", "displayname":"Applications"});
        break;
      case "Versions":
        routeHistory.add({"name": "Apps", "displayname":"Applications"});
        routeHistory.add({"name": "Versions", "displayname":"Versions","params":instruction.component.params});
        break;
      case "Account":
        break;
      case "Administration":
        break;
    }
  }
}