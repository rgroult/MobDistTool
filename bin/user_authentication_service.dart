import 'dart:io';
import 'package:option/option.dart';
import 'package:rpc/rpc.dart';
import 'package:rpc/src/context.dart' as context;
import 'package:shelf_auth/shelf_auth.dart';
import 'dart:async';
import 'model/model.dart';
import 'managers/users_manager.dart' as users;
import 'package:shelf_exception_handler/shelf_exception_handler.dart';

class User extends Principal {
  final MDTUser dbUser;
  User(MDTUser user ){
    super(user.email);
    dbUser = user;
  }
}
/*lookupByUsernamePassword(String username, String password) async =>
  authenticateUser(username,password);
*/
Future<Option<User>> authenticateUser(String username, String password ) async {
  //search user
  var user = await users.authenticateUser(username, password);
  if (user!=null) {
    return new Some(new User(user));
  }
  throw new RpcError(401, 'InvalidUser', 'User does not exist or bad password');
  //return new None();
}


func usernameLookup(String username) async =>
   new Some(new Principal(username));




//usefull
// http://stackoverflow.com/questions/32255622/using-dart-rpc-and-shelf-auth-for-some-procedures
// https://pub.dartlang.org/packages/shelf_auth
@ApiClass(name: 'users' , version: 'v1')
class UserAuthenticationService {

  //user/login
  //http://localhost:8080/api/users/v1/login?login=toto&password=titi&type=test
  @ApiMethod(method: 'GET', path: 'login')
  EchoResponse userGetLogin() {
    var test = context.context;
    return new EchoResponse()
        ..result="login "+"login" + " password :"+"password" + " type :"+"type" ;
  }

  @ApiMethod(method: 'POST', path: 'login')
  EchoResponse userPostLogin(EmptyMessage message) {
    var test = context.context;
    var authentContext = authenticatedContext;
    return new EchoResponse()
      ..result="login "+"login" + " password :"+"password" + " type :"+"type" ;
  }

  ///*{String login , String password,String type token or session}*/

  //user/logout
  //only work for session login
  @ApiMethod(method: 'GET', path: 'logout')
  VoidMessage userLgout() {

  }
}

class EmptyMessage {

}

class EchoResponse {
  String result;
  EchoResponse();
}