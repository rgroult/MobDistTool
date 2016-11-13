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
  var maxLines = 150;
  LogComponent(this._mdtQueryService){
    reloadLogs();
  }

  void displayConsoleLogs(){
    logSelected = "Console";
    reloadLogs();
  }

  void displayActivityLogs(){
    logSelected = "Activity";
    reloadLogs();
  }

  Future reloadLogs() async{
    logLines = "Loading ...";
    try{
      logLines = await  _mdtQueryService.loadLogs(logSelected,maxLines: maxLines);
    }catch(e){
      logLines = "Error loading logs : $e";
    }
  }
}