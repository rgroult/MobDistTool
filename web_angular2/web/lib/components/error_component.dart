import 'package:angular2/core.dart';
import '../model/errors.dart';

@Component(
    selector: 'error_comp',
    inputs: const ['error'],
    templateUrl: 'error_component.html')
class ErrorComponent {
  UIError error = null;
  void hide(){
    error = null;
  }
}