import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import 'dart:async';
import '../commons.dart';
import '../services/mdt_query.dart';

@Component(
    selector: 'log_console',
    directives: const [materialDirectives],
    templateUrl: 'log_console_component.html'
)
class LogConsoleComponent extends BaseComponent {
  MDTQueryService _mdtQueryService;
  var logSelected = "Console";
  var logLines = "Select log ...";
  var maxLines = '150';
  LogConsoleComponent(this._mdtQueryService){
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
      logLines = await  _mdtQueryService.loadLogs(logSelected,maxLines: int.parse(maxLines));
    }catch(e){
      logLines = "Error loading logs : $e";
    }
  }
}