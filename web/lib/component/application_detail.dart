import 'package:angular/angular.dart';
import 'base_component.dart';
import '../model/mdt_model.dart';
import 'application_list.dart';

@Component(
    selector: 'application_detail',
    templateUrl: 'application_detail.html',
    useShadowDom: false
)
class ApplicationDetailComponent extends BaseComponent  {
  ApplicationListComponent _parent;
  String _appId;
  MDTApplication app;
  Map<String,List<MDTArtifact>> groupedArtifacts = new Map<String,List<MDTArtifact>>();
  List<String> allSortedIdentifier = new List<String>();
  List<MDTArtifact>  applicationsLastestVersion = new List<MDTArtifact>();
  List<String> allAvailableBranches = new List<String>();
  String currentBranchFilter = "";

  List<MDTArtifact>  applicationsArtifacts = new List<MDTArtifact>();
  ApplicationDetailComponent(RouteProvider routeProvider,this._parent){
    print("ApplicationDetailComponent created");
    _appId = routeProvider.parameters['appId'];
    app = _parent.allApps.first;
    loadArtifacts();
    sortArtifacts();

    RouteHandle route = routeProvider.route.newHandle();
    route.onLeave.listen((RouteEvent event) {
      _parent.isApplicationSelected = false;
    });

  }

  void sortArtifacts() {
    groupedArtifacts.clear();
    allSortedIdentifier.clear();
    allAvailableBranches.clear();
    //grouped artifacts
    for (var artifact in applicationsArtifacts) {
      String key = "${artifact.sortIdentifier} - ${artifact.branch}";
      if(groupedArtifacts[key] == null){
        groupedArtifacts[key] = new List<MDTArtifact>();
        allSortedIdentifier.add(key);
        allAvailableBranches.add("_${artifact.branch}");
      }
      groupedArtifacts[key].add(artifact);
    }
    allAvailableBranches = allAvailableBranches.toSet().toList()..sort();
   // allAvailableBranches.insert(0, "_All");
  }

  void loadArtifacts() {
    var artifact = new MDTArtifact({
      "uuid" : "dsdsdd",
      "branch" : "master",
      "name" : "prod",
      "creationDate" : new DateTime(2015),
      "version" : "X.Y.Z",
      "sortIdentifier" : "X.Y.Z"
    });
    var artifact1 = new MDTArtifact({
      "uuid" : "dsdsdd",
      "branch" : "develop",
      "name" : "prod",
      "creationDate" : new DateTime(2015),
      "version" : "X.Y.Z",
      "sortIdentifier" : "X.Y.Z"
    });
    var artifact2 = new MDTArtifact({
      "uuid" : "dsdsdd",
      "branch" : "master",
      "name" : "dev",
      "creationDate" : new DateTime(2015),
      "version" : "X.Y.Z",
      "sortIdentifier" : "X.Y.Z"
    });
    var artifact3 = new MDTArtifact({
      "uuid" : "dsdsdd",
      "branch" : "develop",
      "name" : "dev",
      "creationDate" : new DateTime(2015),
      "version" : "X.Y.ZZ",
      "sortIdentifier" : "X.Y.ZZ"
    });
    var artifact4 = new MDTArtifact({
      "uuid" : "dsdsdd",
      "branch" : "develop",
      "name" : "prod",
      "creationDate" : new DateTime(2015),
      "version" : "X.Y.ZZ",
      "sortIdentifier" : "X.Y.ZZ"
    });
    //applicationsArtifacts = new List<MDTArtifact>();
    applicationsArtifacts.add(artifact);
    applicationsArtifacts.add(artifact1);
    applicationsArtifacts.add(artifact2);
    applicationsArtifacts.add(artifact3);
    applicationsArtifacts.add(artifact4);
   // applicationsLastestVersion = new List<MDTArtifact>();
    applicationsLastestVersion.add(artifact);
    applicationsLastestVersion.add(artifact2);
  }
}