import 'package:angular/angular.dart';
import 'dart:core';
import 'package:xcvbnm/xcvbnm.dart';

@Component(
    selector: 'input_password',
    templateUrl: 'input_password.html',
    useShadowDom: false
)
class InputPasswordComponent {
  @NgOneWay('placeholder')
  String placeholder;
  @NgTwoWay('text')
  String text;
  var checker=new Xcvbnm();
  var strengthText = {
    0: "Worst",
    1: "Bad",
    2: "Weak",
    3: "Good",
    4: "Strong"
  };
  var gaugeColor = {
    0: "primary",
    1: "danger",
    2: "info",
    3: "success",
    4: "warning"
  };

  int get gaugeValue => passwordScore*25;
  int get passwordScore => text!=null?checker.estimate(text).score:0;
  bool get displayStrength => (text!=null && text.isNotEmpty);
  String get strength => strengthText[passwordScore];
}
