import 'package:angular/angular.dart';
import 'dart:async';
import 'base_component.dart';
import '../service/mdt_query.dart';
import '../model/mdt_model.dart';

@Component(
    selector: 'log_console',
    templateUrl: 'log_console.html',
    useShadowDom: false
)
class LogComponent extends BaseComponent {
  MDTQueryService _mdtQueryService;
  var logSelected = "Console";
  var logLines = "Select log ...";
  LogComponent(this._mdtQueryService){
  }

  void displayConsoleLogs(){
    logSelected = "Console";
    reloadLogs("console");
  }

  void displayActivityLogs(){
    logSelected = "Activity";
    reloadLogs("activity");
  }

  Future reloadLogs(String name) async{
    logLines = "Loading ...";
    try{
      logLines = await  _mdtQueryService.loadLogs(name);
    }catch(e){
      logLines = "Error loading logs : $e";
    }
  }
}