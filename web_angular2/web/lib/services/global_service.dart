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
  final Location _location;
  GlobalService(this._location,this._mdtQueryService);
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
    if (forceRefresh == false &&_lastAppsRefresh != null &&
        _lastAppsRefresh.add(new Duration(minutes: 5)) < new DateTime.now()) {
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
    _location.go("Apps");
  }
  void goToHome(){
    _location.go("Home");
  }

  void goToApplication(String appIdentifier){
    _location.go("Home");
  }


}

