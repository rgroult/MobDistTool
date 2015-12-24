import 'package:angular/angular.dart';

@Injectable()
class MDTQueryService {
  final Http _http;

  MDTQueryService(Http this._http) {
  }
}