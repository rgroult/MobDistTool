import 'dart:async';
import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:angular2/router.dart';
import '../commons.dart';

@Component(
  selector: 'activation_comp',
    directives: const [materialDirectives,ErrorComponent],
  templateUrl: 'activation_component.html'
)
class ActivationComponent extends BaseComponent implements OnInit{
  final RouteParams _routeParams;
  MDTQueryService _mdtQueryService;
  String activationToken;
  var activationSucessfull = false;

  ActivationComponent(this._routeParams,this._mdtQueryService){
    activationToken = _routeParams.params["token"];
    print("token $activationToken");
  }

  void ngOnInit() {
      if (activationToken != null){
        _checkActivationToken(activationToken);
      }
  }

  Future _checkActivationToken(String token) async{
    try{
      activationSucessfull = false;
      isHttpLoading = true;
      await _mdtQueryService.activateUser(token);
      activationSucessfull = true;
    }on ActivationError catch(e){
      error = new UIError(ActivationError.errorCode, e.message, ErrorType.ERROR);
    }
    catch(e){
      error = new UIError("UNKNOWN ERROR","Unknown error $e",ErrorType.ERROR);
    }finally {
      isHttpLoading = false;
    }
  }
}