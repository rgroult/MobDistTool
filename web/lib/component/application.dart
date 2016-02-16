import 'package:angular/angular.dart';
import 'application_list.dart';
import 'application_detail.dart';
import 'application_edition.dart';
import 'confirmation_popover.dart';
import 'dart:html' as dom;

class MDTApplicationModule extends Module {
  MDTApplicationModule() {
    bind(ApplicationListComponent);
    bind(ApplicationDetailComponent);
    bind(ApplicationEditionComponent);
    bind(ConfirmationComponent);
    bind(FileModel);
  }
}
