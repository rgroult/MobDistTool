import 'package:shelf_auth/shelf_auth.dart';
import '../model/model.dart';

class User extends Principal {
  MDTUser dbUser;
  User(MDTUser user ):super(user.email){
     this.dbUser = user;
  }
}

class Response {
  int status;
  Map<String,String> data;
  Response(this.status,this.data);
}