import 'dart:async';
import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import '../commons.dart';
import '../components/edit_application_component.dart';

@Component(
    selector: 'application_list',
    templateUrl: 'application_list_component.html',
    directives: const [materialDirectives],
    providers: materialProviders,
)
class ApplicationListComponent extends BaseComponent implements OnInit,EditAppComponentAware{
    ModalService _modalService;
    final allPlatformsFilters = ['All','iOS','Android'];
    var currentPlatformFilter = '';
    var currentSelectedPlatform = 'All';
    List<String> applicationFavorites = new List<String>();
    var isFavoritesExpanded = false;
    var isOthersAppExpanded = false;
    String appSearchFilter="";
    void set searchFilter(String filter) {
      appSearchFilter = filter.toLowerCase();
      filterApplications();
    }
    String get searchFilter{
      return appSearchFilter;
    }

    ApplicationListComponent(GlobalService globalService,this._modalService) : super.withGlobal(globalService);
    List<MDTApplication> allFilteredApplications = [];
    List<MDTApplication> favoritesFilteredApplications = [];

    Future ngOnInit() async {
      await refreshApplications();
      isFavoritesExpanded = favoritesFilteredApplications.isNotEmpty;
      isOthersAppExpanded = !isFavoritesExpanded;
    }

    void selectApplication(String appUUID){
      global_service.goToApplication(appUUID);
    }

    void manageLoadAppResult(dynamic errorOccured){
      if (errorOccured == null){
        return;
      }
    }

    void updateNeeded(){
      refreshApplications(forceRefresh:true);
    }

    void forceRefresh(){
      refreshApplications(forceRefresh: true);
    }

    Future refreshApplications({bool forceRefresh: false}) async{
      var errorOccured = await global_service.loadAppsIfNeeded(forceRefresh:forceRefresh);
      manageLoadAppResult(errorOccured);
      filterApplications();
    }

    void filterApplications(){
       var apps = global_service.allApps;
       applicationFavorites = global_service.connectedUser.favoritesApplicationsUUID;
        allFilteredApplications.clear();
        favoritesFilteredApplications.clear();
        String currentFilter = currentPlatformFilter.toLowerCase();
        for (MDTApplication app in apps){
            if (currentPlatformFilter.length>0 && app.platform.matchAsPrefix(currentFilter) == null){
                continue;
            }
            if (appSearchFilter.length>0 && !app.name.toLowerCase().contains(appSearchFilter)){
              continue;
            }
            allFilteredApplications.add(app);
            //favoritesFilteredApplications.add(app);
            if (isFavorite(app)){
                favoritesFilteredApplications.add(app);
            }
        }
    }

    void selectFilter(String platform){
      if (platform == "All"){
        currentPlatformFilter = "";
      }else {
        currentPlatformFilter = platform;
      }
      currentSelectedPlatform = platform;
      filterApplications();
    }

    bool isFavorite(MDTApplication app){
      return applicationFavorites.contains(app.uuid);
    }

    void createApplication(){
      _modalService.displayCreateApplication(this);
    }
}