import 'dart:async';
import 'dart:html';
import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import '../commons.dart';
import '../model/mdt_model.dart';
import '../services/mdt_query.dart';

@Component(
    selector: 'edit_app_comp',
    templateUrl: 'edit_application_component.html',
    directives: const [materialDirectives,ErrorComponent],
    providers: materialProviders
    )
class EditAppComponent extends BaseComponent {
  MDTQueryService _mdtQueryService;
  EditAppComponent(this._mdtQueryService, GlobalService globalService) : super.withGlobal(globalService);
  @Input()
  MDTApplication application;

  @Input()
  var isModeEdition = false;

  var appName = '';
  var appDescription = '';
  String appPlatform;
  String appIcon ="images/placeholder.jpg";
  File appIconFile;
  bool maxVersionCheckEnabled = false;

  Future onInputChange(dynamic event) {
    var file = event.currentTarget.files.first;

    appIconFile = file;
    FileReader reader = new FileReader();
    reader.onLoadEnd.listen((e) => createImageElement(file,reader.result));
    reader.readAsDataUrl(file);
  }

  void createImageElement(File file,String base64) {
    //print(base64);
    appIcon = "$base64";
  }
}