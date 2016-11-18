import 'package:angular2/core.dart';
import '../model/errors.dart';
import '../services/global_service.dart';

class BaseComponent {
  GlobalService get global_service => _global_service;
  GlobalService _global_service;
  var isHttpLoading = false;
  var error = null;
  BaseComponent.withGlobal(GlobalService globalService){
    this._global_service = globalService;
  }
  BaseComponent();
}