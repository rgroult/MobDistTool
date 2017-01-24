import 'package:angular2/core.dart';
import '../services/version_service.dart';

@Component(
    selector: 'bottom_bar',
    templateUrl: 'bottom_bar_component.html')
class BottomBarComponent {
  //String mdt_version = "TO DO";
  VersionService _versionService;
  String get currentVersion => _versionService.version;
  BottomBarComponent(this._versionService);
}