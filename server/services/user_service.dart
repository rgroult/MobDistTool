// Copyright (c) 2016, the Mobile App Distribution Tool project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:option/option.dart';
import 'package:rpc/rpc.dart';
import 'package:shelf_auth/shelf_auth.dart';
import "package:log4dart/log4dart_vm.dart";
import 'package:mailer/mailer.dart';
import 'package:validator/validator.dart';
import 'package:jwt/json_web_token.dart';
import 'package:xcvbnm/xcvbnm.dart';
import '../model/model.dart';
import '../managers/src/users_manager.dart' as users;
import '../managers/src/apps_manager.dart' as apps;
import 'json_convertor.dart';
import 'model.dart';
import '../config/config.dart' as config;
import '../utils/utils.dart';
import '../managers/errors.dart';
import '../activity/activity_tracking.dart';


final _logger = LoggerFactory.getLogger("UserService");
UserService userServiceInstance = null;

Future<Option<User>> authenticateUser(String username, String password)  {
  return userServiceInstance.authenticateUser(username,password);
}

Future<Option<User>> findUser(String username) {
  return userServiceInstance.findUser(username);
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
  var loginDelay=0;
  var passwordStrengthRequired  = 0;
  var passwordChecker = new Xcvbnm();
  UserService(){
    userServiceInstance = this;
    loginDelay = int.parse(config.currentLoadedConfig[config.MDT_LOGIN_DELAY]);
    passwordStrengthRequired = int.parse(config.currentLoadedConfig[config.MDT_PASSWORD_MIN_STRENGTH]);
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
  Future<Option<User>> authenticateUser(String username, String password) async {
    await new Future.delayed(new Duration(milliseconds: loginDelay));
    //search user
    var user = await users.findUser(username.toLowerCase(), password);
    if (user != null) {
      if (user.isActivated){
        var authenticatedUser = new User(user);
        authenticatedUser.passwordStrengthFailed = !checkPasswordStrength(password);
        trackUserConnection(username,true);
        return new Some(authenticatedUser);
      }else { _logger.info("Login Failed: User ${user.email} not activated");}
    }else {
      _logger.info("Login Failed: ($username) Bad login or password");
    }
    trackUserConnection(username,false);
    return new None();
  }
  Future<Option<User>> findUser(String username) async {
    var user = await users.findUserByEmail(username.toLowerCase());
    if (user != null && user.isActivated) {
      return new Some(new User(user));
    }
    return new None();
  }
  bool checkPasswordStrength(String password){
    if (passwordStrengthRequired > 0){
      var result = passwordChecker.estimate(password);
      return result.score >= passwordStrengthRequired;
    }
    return true;
  }

  void updatePassword(MDTUser user,String newPassword) {
    if (checkPasswordStrength(newPassword)){
      if (user != null) {
        user.password = users.generateHash(newPassword, user.salt);
      }
      return;
    }
    throw new RpcError(
        400, 'USER_ERROR', "Failure: password strength does not meet the minimum requirements.");
  }

  @ApiMethod(method: 'POST', path: 'register')
  Future<Response> userRegister(RegisterMessage message) async {
    try {
      var userCreated = null;
      if (isEmail(message.email) == false) {
        throw new RpcError(400, 'REGISTER_ERROR', "Bad url format");
      }
      List<String> whiteEmailsDomain = config.currentLoadedConfig[config
          .MDT_REGISTRATION_WHITE_DOMAINS];
      if (whiteEmailsDomain != null && whiteEmailsDomain is List &&
          whiteEmailsDomain.length > 0) {
        bool inWhiteDomains = false;
        for (String domain in whiteEmailsDomain) {
          if (message.email.toLowerCase().endsWith(domain)) {
            inWhiteDomains = true;
            break;
          }
        }
        if (inWhiteDomains == false) {
          throw new RpcError(
              401, 'REGISTER_ERROR', "Registration forbidden for this email");
        }
      }
      try {
        updatePassword(null,message.password);
        userCreated = await users.createUser(
            message.name, message.email.toLowerCase(), message.password,
            isActivated: !needRegistration);
        var jsonResult = await toJson(userCreated);
        if (needRegistration && confirmationUrl != null &&
            emailTransport != null) {
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
          } catch (e) {
            throw new RpcError(
                500, 'REGISTER_ERROR', "Unable to send confirmation email");
          }
        }

        trackUserRegistered(userCreated.email,true);
        return new Response(200, jsonResult);
      } catch (e) {
        trackUserRegistered(message.email,false);
        if (userCreated != null) {
          await userCreated.remove();
        }
        //var error = e;
        //  throw new BadRequestError( e.message);
        throw new RpcError(500, 'REGISTER_ERROR', e.message);
        // ..errors.add(new RpcErrorDetail(reason: e.message));
      }
    }catch(e,stack){
      manageExceptions(e,stack);
    }
  }

  //user/login
  //http://localhost:8080/api/users/v1/login?login=toto&password=titi&type=test
  /*@ApiMethod(method: 'GET', path: 'login')
  Response userGetLogin() {
    var currentUser = currentAuthenticatedUser();
    return new Response(200, toJson(currentUser));
  }*/



  @ApiMethod(method: 'POST', path: 'login')
  Future<Response> userPostLogin(EmptyMessage message) async {
    var currentUser = currentAuthenticatedUser();
    var jsonUser = await toJson(currentUser,isAdmin:true);
    if (authenticatedContext().get().principal.passwordStrengthFailed){
      jsonUser["passwordStrengthFailed"] = true;
    }
    return new Response(200,jsonUser );
  }

  @ApiMethod(method: 'GET', path: 'me')
  Future<Response> userMe() async {
    try {
      var me = currentAuthenticatedUser();
      await me.reRead();
      var response = await toJson(me, isAdmin: true);
      var allAdministratedApps = await apps.findAllApplicationsForUser(me);
      var administratedAppJson = [];
      for (var app in allAdministratedApps) {
        administratedAppJson.add(await toJson(app,isAdmin:true));
        //administratedAppJson.add(toJsonStringValues(app, ['name', 'platform']));
      }
      response['administratedApplications'] = administratedAppJson;
      return new Response(200, response);
    }catch(e,stack){
      manageExceptions(e,stack);
    }
  }

  ///*{String login , String password,String type token or session}*/

  //user/logout
  //only work for session login
  @ApiMethod(method: 'GET', path: 'logout')
  VoidMessage userLogout() {
    return new VoidMessage();
  }

  //Sys admin user
  static void checkSysAdmin(){
    var me = currentAuthenticatedUser();
    if (me.isSystemAdmin == false){
      throw new RpcError(401,"ACCESS_DENIED","Admin Access Denied");
    }
  }

  @ApiMethod(method: 'GET', path: 'all')
  Future<ResponseListPagined> listUsers({int pageIndex,int maxResult}) async{
    try {
      checkSysAdmin();
      var page = 1;
      var limit = 25;
      if (maxResult != null) {
        limit = maxResult + 1;
      }
      if (pageIndex != null) {
        page = pageIndex;
      }
      var numberToSkip = (page - 1) * (limit-1);

      var usersList = await users.searchUsers(page, numberToSkip, limit);
      bool hasMore = false;
      if (usersList.length == limit) {
        hasMore = true;
        usersList.removeLast();
      }
      var responseJson = await listToJson(usersList, isAdmin: true);
      return new ResponseListPagined(responseJson, hasMore, page);
    }catch(e,stack){
      manageExceptions(e,stack);
    }
  }

  @ApiMethod(method: 'PUT', path: 'user')
  Future<Response> updateUser(UpdateUserMessage message) async {
    try {
      var me = currentAuthenticatedUser();
      String email = message.email;

      if (me.email != email && me.isSystemAdmin == false) {
        throw new RpcError(401, "ACCESS_DENIED", "Admin Access Denied");
      }

      //find user
      var user = await users.findUserByEmail(email);

      if (user == null) {
        throw new NotFoundError("User not found");
      }

      if (message.password != null) {
        updatePassword(user,message.password);
        //user.password = users.generateHash(message.password, user.salt);
      }
      if (message.name != null) {
        user.name = message.name;
      }

      //only sysadmin can activated/desactivate and enable sysadmin
      if (me.isSystemAdmin) {
        if (message.sysadmin != null) {
          user.isSystemAdmin = message.sysadmin;
        }
        if (message.activated != null) {
          user.isActivated = message.activated;
        }
      }

      if (message.favoritesApplicationUUID != null){
        await users.updateFavoritesApp(me, message.favoritesApplicationUUID);
      }

      //save user
      await user.save();

      var jsonResult = await toJson(user, isAdmin: true);
      return new Response(200, jsonResult);
    }catch(e,stack){
      manageExceptions(e,stack);
    }
  }

  @ApiMethod(method: 'DELETE', path: 'user')
  Future<Response> deleteUser({String email}) async {
    checkSysAdmin();
    try {
      if (email == null) {
        throw new NotFoundError("User Not Found");
      }

      await users.deleteUserByEmail(email);

      return new OKResponse();
    } on UserError catch (e) {
      throw new NotFoundError(e.message);
    }catch(e,stack){
      manageExceptions(e,stack);
    }
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

class UpdateUserMessage {
  @ApiProperty(required: true)
  String email;
  @ApiProperty(required: false)
  String password;
  @ApiProperty(required: false)
  String name;
  @ApiProperty(required: false)
  bool sysadmin;
  @ApiProperty(required: false)
  bool activated;
  @ApiProperty(required: false)
  List<String> favoritesApplicationUUID;

  UpdateUserMessage();
}

class EmptyMessage {

}

class EchoResponse {
  String result;

  EchoResponse();
}