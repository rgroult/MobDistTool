import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2/platform/common.dart';
import 'dart:html' show window;
import '../model/mdt_model.dart';

enum Platform { ANDROID, IOS, OTHER }

@Injectable()
class GlobalService implements OnInit  {
  final Location _location;
  GlobalService(this._location);

  MDTUser get connectedUser => _currentUser;
  bool get hasConnectedUser => _currentUser != null;
  bool get isConnectedUserAdmin => _currentUser?.isSystemAdmin ?? false;
  bool adminOptionsDisplayed = false;
  Platform currentDevice = Platform.OTHER;

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

  void goToApps(){
    _location.go("Apps");
  }
  void goToHome(){
    _location.go("Home");
  }

  void goToApplication(String appIdentifier){
    _location.go("Home");
  }

  MDTUser _currentUser = null;
  void updateCurrentUser(MDTUser user){
    _currentUser = user;
  }
}

