import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2/platform/common.dart';
import '../commons.dart';
import 'dart:async';
import 'dart:html' show window;
import '../model/mdt_model.dart';

enum Platform { ANDROID, IOS, OTHER }

@Injectable()
class GlobalService implements OnInit  {
  final Router _router;
  GlobalService(this._router,this._mdtQueryService);
  MDTUser _currentUser = null;
  DateTime _lastAppsRefresh = null;
  MDTQueryService _mdtQueryService;

  MDTUser get connectedUser => _currentUser;
  bool get hasConnectedUser => _currentUser != null;
  bool get isConnectedUserAdmin => _currentUser?.isSystemAdmin ?? false;
  bool adminOptionsDisplayed = false;
  Platform currentDevice = Platform.OTHER;
  var allApps = new List<MDTApplication>();

  void updateCurrentUser(MDTUser user){
    _currentUser = user;
  }

  void ngOnInit() {
    _detectBrowser();
  }

  void _detectBrowser(){
    //Detect browser
    var userAgent = window.navigator.appVersion.toUpperCase();
    if (userAgent.indexOf("ANDROID") != -1){
      currentDevice = Platform.ANDROID;
    }else if ((userAgent.indexOf("IPAD") != -1) || (userAgent.indexOf("IPHONE") != -1) || (userAgent.indexOf("IPOD") != -1)){
      currentDevice  = Platform.IOS;
    }
    print("Platform detected $currentDevice  user agent $userAgent");
  }

  Future loadAppsIfNeeded({bool forceRefresh: false}) async {
   // loadMockApps();
    //return new Future.value(null);

    if (forceRefresh == false &&_lastAppsRefresh != null && _lastAppsRefresh.add(new Duration(minutes: 5)).isBefore(new DateTime.now())) {
      return new Future.value(null);
    }
    //update apps
    try {
      allApps.clear();
      var apps = await _mdtQueryService.getApplications();
      if (apps.isNotEmpty) {
        allApps.addAll(apps);
      }
      _lastAppsRefresh = new DateTime.now();
    } catch (e) {
      return new Future.value(e);
    }
    return new Future.value(null);
  }

  void goToApps(){
    _router.navigate(["Apps"]);
  }
  void goToHome(){
    _router.navigate(["Home"]);
  }

  void goToApplication(String appIdentifier){
    _router.navigate(['Versions', {'appid': appIdentifier}]);
  }

  void loadMockApps(){
    var allMocksApps = [{
      "name": "ApplicationDev",
      "platform": "android",
      "adminUsers": [
        {
          "name": "toto",
          "email": "toto@totoC.om"
        }
      ],
      "uuid": "dsdsqd-52fb-44a2-aeee-9aa015ce66b7",
      "description": "test de nectarine"
    },
    {
      "name": "TOD",
      "platform": "android",
      "adminUsers": [
        {
          "name": "frde",
          "email": "fred@toto.com"
        }
      ],
      "uuid": "qsdqsd-110c-450c-be02-acsdz3208",
      "description": "long long description for app"
    },
    {
      "name": "InterneDemo",
      "platform": "android",
      "adminUsers": [
        {
          "name": "oula",
          "email": "oula@yop.com"
        },
        {
          "name": "fxf",
          "email": "fx@yop.com"
        }
      ],
      "uuid": "xc-fa18-47ac-b402-23b6662a2b6c",
      "description": "Application for a bib client"
    }];
    allApps.clear();
    for (Map map in allMocksApps ){
      allApps.add(new MDTApplication(map));
    }
  }
}

