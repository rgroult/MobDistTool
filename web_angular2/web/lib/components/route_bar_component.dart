import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'dart:async';

@Component(
    selector: 'route_bar',
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
  Future handleUrlChange(String url) async {
    var instruction = await _router.recognize(url);
    print ("router instrction $instruction");
    var routeName = instruction.component.routeName;
    routeHistory.clear();
    routeHistory.add({"path": "/home", "name":"Home","status":"active"});
    //ugly swith , should found a better way
    switch (routeName){
      case "Home":
        break;
      case "Apps":
        routeHistory.add({"path": "/apps", "name":"Applications","status":"active"});
        break;
      case "Versions":
        routeHistory.add({"path": "/apps", "name":"Applications","status":"active"});
        routeHistory.add({"path": "/versions", "name":"Versions","status":"active"});
        break;
      case "Account":
        break;
      case "Administration":
        break;
    }
  }
}