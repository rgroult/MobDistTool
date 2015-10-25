import 'package:shelf_auth/shelf_auth.dart';

class User extends Principal {
  final MDTUser dbUser;
  User(MDTUser user ){
    super(user.email);
    dbUser = user;
  }
}

class Response {
  int status;
  Map data;
  Response(this.status,this.data);
}