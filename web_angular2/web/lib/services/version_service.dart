import 'package:angular2/core.dart';

@Injectable()
class VersionService {
  String version;
  VersionService(this.version);
}