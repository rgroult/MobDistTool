import 'dart:async';
import 'package:option/option.dart';
import 'package:rpc/rpc.dart';
import 'package:rpc/src/context.dart' as context;
import 'package:shelf_auth/shelf_auth.dart';
import 'package:shelf_exception_handler/shelf_exception_handler.dart';
import 'package:mailer/mailer.dart';
import 'package:validator/validator.dart';
import 'package:jwt/json_web_token.dart';
import '../model/model.dart';
import '../managers/src/users_manager.dart' as users;
import '../managers/src/apps_manager.dart' as apps;
import 'json_convertor.dart';
import 'model.dart';
import '../config/config.dart' as config;


Future<Option<User>> authenticateUser(String username, String password) async {
  //return new Some(new Principal(("toto")));
  //search user
  var user = await users.findUser(username, password);
  if (user != null) {
    if (user.isActivated){
      return new Some(new User(user));
    }
  }
  return new None();
}

Future<Option<User>> findUser(String username) async {
  var user = await users.findUserByEmail(username);
  if (user != null) {
    return new Some(new User(user));
  }
  return new None();
}

usernameLookup(String username) async =>
  findUser(username);

MDTUser currentAuthenticatedUser() {
  var user = authenticatedContext().get().principal.dbUser;
  return user;
}


//usefull
// http://stackoverflow.com/questions/32255622/using-dart-rpc-and-shelf-auth-for-some-procedures
// https://pub.dartlang.org/packages/shelf_auth
//discovery : http://localhost:8080/api/discovery/v1/apis/users/v1/rest
@ApiClass(name: 'users', version: 'v1')
class UserService {
  JsonWebTokenCodec jsonWebToken;
  bool needRegistration = true;
  var emailTransport;
  var confirmationUrl;
  UserService(){
    jsonWebToken = new JsonWebTokenCodec(secret: config.currentLoadedConfig[config.MDT_TOKEN_SECRET]);
    needRegistration = config.currentLoadedConfig[config.MDT_REGISTRATION_NEED_ACTIVATION] == "true";
    Map smtpConfig = config.currentLoadedConfig[config.MDT_SMTP_CONFIG];
    if (needRegistration && smtpConfig != null) {
      var options = new SmtpOptions()
          ..hostName = smtpConfig["serverUrl"]
          ..username = smtpConfig["username"]
          ..password = smtpConfig["password"]
          ..secured = true;

      emailTransport = new SmtpTransport(options);
      confirmationUrl = '/web/index.html#/activation?token=';
      if (config.currentLoadedConfig[config.MDT_SERVER_URL] != null) {
          confirmationUrl = '${config.currentLoadedConfig[config.MDT_SERVER_URL]}${confirmationUrl}';
  }
    }
  }
  @ApiMethod(method: 'POST', path: 'register')
  Future<Response> userRegister(RegisterMessage message) async {
    var userCreated = null;
    if (isEmail(message.email) == false){
      throw new RpcError(400, 'REGISTER_ERROR', "Bad url format");
    }
    List<String> whiteEmailsDomain = config.currentLoadedConfig[config.MDT_REGISTRATION_WHITE_DOMAINS];
    if (whiteEmailsDomain != null && whiteEmailsDomain is List && whiteEmailsDomain.length >0){
      bool inWhiteDomains = false;
      for(String domain in whiteEmailsDomain){
        if (message.email.toLowerCase().endsWith(domain)){
          inWhiteDomains =true;
          break;
        }
      }
      if (inWhiteDomains == false){
        throw new RpcError(401, 'REGISTER_ERROR', "Registration forbidden for this email");
      }
    }
    try {
      userCreated = await users.createUser(message.name, message.email, message.password,isActivated:!needRegistration);
      var jsonResult = toJson(userCreated);
      if (needRegistration && confirmationUrl!= null && emailTransport!=null){
        jsonResult["message"] = "A activation email was sent.";
        //send confirmation email
        //activation token
        final token = {
          'user': userCreated.email,
          'token': userCreated.activationToken
        };
        var activationToken = jsonWebToken.encode(token);
        var url = '$confirmationUrl${activationToken}';
        var envelope = new Envelope()
          ..recipients.add(userCreated.email)
          ..subject = 'MDT Account activation'
          ..html = '<p> Please follow this <a href="$url">link</a> to activate your account</p>';
        try {
          await emailTransport.send(envelope);
        }catch(e){
          throw new RpcError(500, 'REGISTER_ERROR', "Unable to send confirmation email");
        }
      }

      return new Response(200, jsonResult);
    }catch (e) {
      if (userCreated != null){
        await userCreated.remove();
      }
      //var error = e;
      //  throw new BadRequestError( e.message);
      throw new RpcError(500, 'REGISTER_ERROR', e.message);
      // ..errors.add(new RpcErrorDetail(reason: e.message));
    }
  }

  //user/login
  //http://localhost:8080/api/users/v1/login?login=toto&password=titi&type=test
  @ApiMethod(method: 'GET', path: 'login')
  Response userGetLogin() {
    var currentUser = currentAuthenticatedUser();
    return new Response(200, toJson(currentUser));
  }

  @ApiMethod(method: 'POST', path: 'login')
  Response userPostLogin(EmptyMessage message) {
    var currentUser = currentAuthenticatedUser();
    return new Response(200, toJson(currentUser));
  }

  @ApiMethod(method: 'GET', path: 'me')
  Response userMe() {
    var me = currentAuthenticatedUser();
    var response = toJson(currentUser, isAdmin:true);
    var allAdministratedApps = apps.findAllApplicationsForUser(me);
    var administratedAppJson = [];
    for (var app in allAdministratedApps){
      administratedAppJson.add(toJsonStringValues(app,['name','platform']));
    }
    response['administratedApplications'] = administratedAppJson;
    return new Response(200, response);
  }

  ///*{String login , String password,String type token or session}*/

  //user/logout
  //only work for session login
  @ApiMethod(method: 'GET', path: 'logout')
  VoidMessage userLgout() {

  }
}

class RegisterMessage {
  @ApiProperty(required: true)
  String email;
  @ApiProperty(required: true)
  String password;
  @ApiProperty(required: true)
  String name;

  RegisterMessage();
}

class EmptyMessage {

}

class EchoResponse {
  String result;

  EchoResponse();
}