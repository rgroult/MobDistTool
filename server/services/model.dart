import 'package:shelf_auth/shelf_auth.dart';
import 'package:rpc/rpc.dart';
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

class OKResponse extends Response {
  OKResponse():super(200,{});
}

class NotApplicationAdministrator extends RpcError {
  NotApplicationAdministrator():super(401, 'Forbidden', 'You are not administrator on this app');
}