import 'package:angular/angular.dart';
import 'application_list.dart';
import 'application_detail.dart';

class MDTApplicationModule extends Module {
  MDTApplicationModule() {
    bind(ApplicationListComponent);
    bind(ApplicationDetailComponent);
  }
}
