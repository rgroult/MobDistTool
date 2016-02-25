import 'package:angular/angular.dart';
import 'mdt_conf_query.dart';

abstract class MDTQueryServiceHttpInterceptors{
  var lastAuthorizationHeader = '';
  HttpInterceptors interceptors;

  void configureInjector(HttpInterceptors _interceptors){
    interceptors = _interceptors;
    var headerInterceptor = new HttpInterceptor();
    headerInterceptor.request = (HttpResponseConfig request) {
      if (lastAuthorizationHeader.length>0 && mdtServerApiRootUrl.matchAsPrefix(request.url) != null){
        //print("Add authoriztion to url ${request.url}");
        request.headers['authorization'] = lastAuthorizationHeader;
      }
      return request;
    };
    headerInterceptor.response = (HttpResponse response){
      if (response.status == 401) {
        lastAuthorizationHeader = '';
      }
      var newHeader = response.headers('authorization');
      if (newHeader != null) {
        lastAuthorizationHeader = newHeader;
      }
      return response;
    };

    interceptors.add(headerInterceptor);
  }
}