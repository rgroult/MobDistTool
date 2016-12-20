import 'dart:async';
import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import '../commons.dart';

@Component(
    selector: 'administration_comp',
    templateUrl: 'administration_component.html',
    directives: const [materialDirectives,ErrorComponent],
    providers: materialProviders,
    )
class AdministrationComponent extends BaseComponent {

}