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

          var htmlContent = """
            <html>
            <body>
              <div style='text-align: center'>
                <img src='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEAAAABOCAYAAACQYxCuAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAACXBIWXMAAAsTAAALEwEAmpwYAAADSGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS40LjAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iCiAgICAgICAgICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIgogICAgICAgICAgICB4bWxuczpleGlmPSJodHRwOi8vbnMuYWRvYmUuY29tL2V4aWYvMS4wLyI+CiAgICAgICAgIDx4bXA6TW9kaWZ5RGF0ZT4yMDE2LTAyLTI0VDIyOjAyOjAyPC94bXA6TW9kaWZ5RGF0ZT4KICAgICAgICAgPHhtcDpDcmVhdG9yVG9vbD5QaXhlbG1hdG9yIDMuNC4yPC94bXA6Q3JlYXRvclRvb2w+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgICAgIDx0aWZmOlJlc29sdXRpb25Vbml0PjI8L3RpZmY6UmVzb2x1dGlvblVuaXQ+CiAgICAgICAgIDx0aWZmOkNvbXByZXNzaW9uPjU8L3RpZmY6Q29tcHJlc3Npb24+CiAgICAgICAgIDxleGlmOlBpeGVsWERpbWVuc2lvbj44MDI8L2V4aWY6UGl4ZWxYRGltZW5zaW9uPgogICAgICAgICA8ZXhpZjpDb2xvclNwYWNlPjE8L2V4aWY6Q29sb3JTcGFjZT4KICAgICAgICAgPGV4aWY6UGl4ZWxZRGltZW5zaW9uPjk4MzwvZXhpZjpQaXhlbFlEaW1lbnNpb24+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgoXu+DYAAAaIUlEQVR4AdVcC3RV1Znee5/XPfeRkEAAES3yGCERbQtVIFiSUZxWRUQNM+1Mu2ydpXZabdVaq7WLa7tqddra53SqXdXVrtYqqdZ3tbokVHmooE41CYr44iEkkJDkvs49jz3ff849l5ubG5IgVtjK3efsx7//1/73v/+9Tzg7gpOUjLe1MaW5mTmEpmSSb+g8fyFnfUtdL79EcGWOZFOWNtbf++pq2aKs5K3uWMlRx9rhH9V+zZomlfM2Itx5rvPL413Z+bl13oIvKNw+2YwSM2xmZSNMMNMknOrauvmh4HZEMmCNbFKbA+LZus4zrrHlC9clEk6dY7ssm/VYqp/bjEsFFLtcdfJEeFNTnTysDAjUr0lhrI3As+ZmXxqHMsaY+qxZw3ziN7/RMjNrvXtXPN67OJu12QARzTho5grjTFEULjxPpj3P6aMBWluHDkPToq6t1deMtWuZl0wyr7xVRQ0g4jEUOBoS3Ub9QhU7JE6XD1zp3Sce833D68vPzFlvPRhP2NGBfgnChYDSa6T4hSQF5O+6Yr9mVPVSWUdHAyoPcCEpmSi3CVSW5IOZEBIVAmYHiGdsQ+c/X4z3Uzwmn1xcv+axQiPqU8Sk2PF9PtCcJy2DkWvy5M6nVS3H7Twn9daHguZONMbUTFrfsLjhhUXl9SEN6zo/tZB57kWeZ79rjk/8ev6UhzPlTABnS1JR8oyta1/4u+qavrvMWM/XqqsHHl3f0XwttQTwwX1Kuh/q4+rVLbD0bc6LW744xZO77tP0HHfyYhjiAyxUVUBNzZfojTQnHBv4KaS9Gzv/5UJN7V4fq+q+esLE/p9Y+7uekDKpkgYQg8L2g4iRrMV/39h5zjxNtz7Xs8+S6ZTMZrMWCE9d9/d3vlQD4G5SJgf1C4Edat7R0uprVNbd+tNEVb42n+N5LHk6EK2YUCxclzOhRP7mN2hq8jMijPCjF1f2fUs3HBhML7Nvr20nqp3Fz2/Z2EJ1bW1k24JUkRDp2QFHJSdgivRNh5pmrDrodVOh92HISPVJKuu3rPiUpmcu6u9zPMgH8x1GpyinQQN5qiqVdErpjWvj26imiTUNMW5AO+0Ce8440eJKDywVsqgp1I9SGQNafUALG/76nG1HHqmbrKuK6unoS5AUtyfny2TVKr/v4fjhTU1tvsSk13WFptOjoJ/KpAcjuqaJhYBHHp07/Y97IHXBeXIoA6TQsUrAWLl63SQtkhow2tXEwvsIxNq1bcX2gxhAcyeZDJgixYTP9nRXXSO92lfggDEzmjk2a7yYJACtLHkwBKnJqBLmPpBnctPW82dImW3OZHxeFNWzAhAIQGqQPgRc97OgvqWIy+bN83wJP9vedHkkmjrVsT1wp/bdnq667znuxE/Pn5LMEMNAY2UGEECqpLm0ePZDAwvnrLktop58hucae+w8kOPpr258bdnilZhn5KxUQHBMRdOnv+kLIJ/ff2aiipmey8nzGyQUAgh8wpSvHqdCPeI/bjzx/hdW+wYvcH/JkM6fv9netO3zx3OWudlxHCyTmif4pAsW1j9x45K5D26nFQAMLxJPQIcMRoUkFWLC+vVTzY/P+nk3V6pvUFWd6brNXKf7R9SGPDVqQ8+Hmt6ct9lHxmPu6Qx40biVYKGckhVPcKO/T3+tTrvweiroYCCpkFoKhtSy3rw1ErVqVFVhiqj+8YI5rZsf28oMrABDfADqWpEBVEHILFq0I0tELpr91J1WznyKyDWj1qnr2s+4htrcsfnA8kPvY0kElzQJnIad8ubaUFcUVcKHiLSw7hvpAWOPakw7b9asK63AeCZ9Bm7aNE8Dvt6Gzk8v07TMv7mwo7ms8bqMn/dtwun5PyTtinYCdZUGpD7FFC4Zwh1/TS6rOXnbBqL9q154/bPTL5vPbHI3i43H9BDYkS07v1LLpT3ZdUidwIxCAoOg+zQlPDmuRhjZjLnV0E9oPG3Gva+HThM1xZQVpPpbt/7M8GTPDxhtE4QG6Y//xqLjrs4Sc5LJgFEF0IOyERlADgo5GgvmPvR3hSdu0TQNWpBP2M47PyRIHTcFa/ggqKN4aWXtPrE5K12LjU2Ve2Bm0pMNXXDNmFQjZkT07a/+vaKdOn/+rHu3EUGl+5IlSwIhdtn3fSdiWicqimD5XOy+BbMfexATxGfOwdAZkQHUmTYSlC+Ys+qmbMbocIGtbmRXrGs/6yIymoQU1Y8l+R4JOuQsJwFpq1izMR2Yp6hMxBNCMwxVyWVjm9zcpHMb69d+bsGsn/eT5Ena4Tj+rpH2Dh3LPs5Y6lrbdlg2o/ca7ISrqU1964EVIuxTno/KkodEct5sb3j1099UFPsh14V3yPbf2t6efLyhIZlqb2/Qu7rqfEZ1d9dJGCVvOKNGSLQV9u+KklEMQ6qaJpgN/yuTZv2ZlPE04/HfNNb/9RFqu3o1U6ZPnyfenFfnERPQm2H/y9be1OaP58l9PzRMm2uaztJO4jvz63/3brClbvUDKQRjuDQyAzA118B1HBho8y3uwpP+8vC69iU/1wz3ilg8P70v3XYLgH+loaHd35eXDgSJKm2siTfBU4MR8md1WE9MomdNrdqfSZvPWiLWKb0Y4j9VbYtm37OL6ojwuk9M05pPeDvH2Gasw5upuJDa/Hxjx1n/pZl7mz3Upvq1Jxobnv4JxuWtHd2C8oMJgQAUjY4PrexHwsDxkjBTe1cyPtD90vFwwpe7csfNkqWwXprwymO/5lzsgAL3ChF5XVWr35w/6/x3OF8JtIJEyJBBJc9vJKRu38Q0MrBhX8qfb794Mld6Zrgsf4LjZo+Hcazh0qySrHclF5lxmh5lnj31ei9++k/J+IV9Sw1mWFaaD8cADsNXjMWt71y2RMr+/8CMPZNzZ5qme8zKub4EyVQnqsg1FcyDQuahB3ZeYPnU3uJMfY4z4ynVmPDMqTPv2R4OTDZj3rxlYERgnX3mvD3NYNPedpp5EP/btO3S6nxux0ImcmdImWuU0p6tql4Npgv4D0j+NsVl6QEYDk8AF8JBw0Ki9mIZ2CBk5O4J+vI/0ZKJKSxWrUqifuhqMIQBhAwhSlJ65tVzT+Gi94e6ljvTiLjMsjwQiLHIxaYWQSKnKZA0VnR0Ewpw0XTsaHSYckdgXisDXETWeJ72+2lV5z5yXEFCtLokEvN4qWFb/8pZi6SS+3cmc+fpEXeqYXjMwbqezyMnneCg3PdVNcm5Cm/fVZnMQ90zqMtzcthMMw7N1FgmxbdyVp1c1PDU3YRqpcBpSIRPChFPFNDLxi1Lv+p6+26LxlyRTpFsieUcrqTkBSYN6kt9UO5zIHhEQ+bvI7mi0HJGGqKwXEbdJlnszqg+4dcfn9XaHfRbo27YcstKKQcu5yJ7ejQqfWbbeervj4uxJK1YyGnYPItop7uaBhdCOhiXnKg8XN8B6Ti7mettB2MsETHjqqqCERnjDxPVf72EtKF8WpcSwaEq9M9b37705qqa3uv7+mDpPYrF+R5faVvCeyyJMISvK4VhcGGYKuvfz3oVZfwtnEXfdN09q+JVzkmua0Nb0BQOELEaD4OcrAKDfYJV5VhPKNW0x4WDr3MholIRMQjAAAMyLG+/JW2nEyLVRU2trvT3xp47LrGimbSP9g0rVwZ7iCJRpI4Uf4ebe3W8av+P+vtp94OoCxuMxFiortCWlMcjzdA0CZ9KhzaTYC1EexHhhXJRtBcFRbwqwPCLYBeQF+wkAAaMiEshjmW69hGpKrVYVrtl1oYZkrY7riai9/eZjzXWrzuHABAixGJ/oNBSkrFT1F1tdt5CEwH1Awc+qIS57O+4mAeqFZoug6Q98rCEejmfXBBGC4AjNfVkxzQahOukZMb+G5ee642rNbT+vujNjXOe+VYocH8++8ompVjfufDliJmdm80Qa6UWqtxBkSkaJUJmdNIrg0c2p5ySsiaDXyE8otSX4WDGHWCKJ3uZqsxwY5HToAk90ISnIXFTEQgQcXnsvIX1D79IghdtcD0I/IbOs6+MJ/IgnsLQFIIGVgdBi5iD/2GIpBKvEipOa+BUES2Y62NLBxklAERjFRKIxh4hIpUExsSSqBAOqCu0oIyGp0DIeOa425Rs7v8w3SZwXTkFtjJlR+OolV3fJXgUGfIHX7/9KlMOrP+7pmdnWhaHYzOiOmIkyaJRhWcz2g4IYzPnyjGqbp/qwZAhYPlBTB/JheQRQ8dWV3sFMYQ3sOrONaP2zGyGPF7MpBJNCrQXK4/slVF9qaOqtSKVexpoZ4SiRjAlJjUtmvOXtf4clwPty03Tnomp74xEfEEanhlVeS474U6j5pwTF5+06fzGhudOY+7ElZ6r54XwLdtYNYGEMlwihgM1ldm5Y77W2LDx5NMbXrjA7jp7Ti5b/T3d0KAYPmbEBD8F2ov1hMe4ZbfjVUhd/SeyEY5/mihTl1DDwMjJ9GeE4uNbBBCAqfCLOW9EGHZqkVcW1T91CcXZaC5heH7a7MdbGR//XTCHOhLAkeFVGKK8CLDdeEIhnfufBfWP/JTqyalpbk46jfVtNzpW7PFoHGwPotgl3UE/o5XmPSXvdnNNnQxGJSC4PBhhnbPxlf+cJNa3X1IrWW6BlQO+5M+OkMBpTzcUmmNrqOnqdqbT/jwMSGIj+xh2dCB8aAh6BNDDVYMKD+cAKk48JjxBjciVpmOvx7bONIJOyqM4LAT6Bf0cAknjtrMDOEeZoh6P54xrRmUt13cuhNva9VFdZxNtG52xEgzpW6mAxM1tmBPG4jqcJ8TbBsZDREhwzBI4uCTbclik78MkDwqYYQ+QoHcaC3aHj+uu8/HlCP5ReaVEXiLjEXihu0Xe3gkvy4YMNU/VEIBwrSbVkZmPxSNwJGH8oB++7lYCVCyDlmQz8Mvdvcs3dVx64/xZd7zHWJKqyTMBqv2X677/Ti7sKOBRp4MncBM2y7OxF+iieXt38wltGMu331kKhe3J3/15KweXmFz1Mr77ovDbStiCZ1XJKHwY8VyXVlLrZL6uswlH0PsvHujHCNieHxyXoBYDuRHYgbxlvqrwmmtM9diOLMtWufldX9cjfV+wcohwBovoiEvcqMaDLmFyuhFDKFau6iFdr0sqxjF77Oz2GbbT9f1IJNOYzUmsXsGSPjxMUhh/J4fDFQlYsVf4uvYFT5uxbDPOAB2wZmQNCKGTMTRoQAXao/VjOU5EYw5Pp1xCl1odFuLD4YIcIZO4Ag2EQZRqn6o61apGYTB/sza66esD4pgCFrzEY9+DWyTqKMbna0+Z+gwevOwNG5VcjnwGG7u9fBU0Cntz4UDwZAs+AOIhO3gC6QEPY7g4srOqbRvxZJuO0jhUe0yDchdyQiQ9jkPmqsl2fi9eYgBB0ht9wnwD17l0XEHOE6ZqUQXHBGe0IwbzmcbgnuPAK/L3Mr7ThucxJDodkhoMadoF5/qjAuZVShe2258fYxUfxv5A6B1CUYmU39eY0CSsmjncnThGx5zXBhwnEoX3a2MAn5E0kL/SkUmlkjL6QkSKbQqo+s3QA5Iq9iC9KPB1MEEFuMPWD24dYAaocN6HwBs1jCJMjl0410HkTjWmTZ1vaAI7P9pXHGqiFTCCf2Eewgnfh8vL24XvH2yeA54xERW2tzvDZyZZ1cfqpkUdkfVcKwq54B6Ebw+OtpyYRjhTIntW/hyWxZhiZKSFSGpfqjbNv9+66Amu5M5yHZaGd0Vegr/TJjDh8yCVLqj4EPUfppzglKfSvsM9U5+D1Q0Hs7RPeZsQJnJbMxA/c2K/VRG77dcieWYPuDCGhekFPSCTTiYRxCMFz/Tkc4WmeJErwcyhdvQU5n7T0n5UUEhkJKh10L4wDkqC8rCmDFYBfhEGYB9oSZ1Lxw/qwralOY2BmyOqFhHMyUR6cB1Ve43cCCSbKsLGAXoB0PA3qAsIHlx24C2spbYhjBBmmJeWh89Bv9LeB2AGsMLeQR72G1wa9qFrRoFfRLFYnzuFhkE/rNw204VUtqg4Sn49iDi75MCMwZsqH/pIesc5I84uSStUoQ9CDApAU1xzEfnQhLENu0HtFQubG/gzxIBAFwZ1OfpePOnIusQUd3x0MkKhtCc7kOgIAfsK7tp8QFWrtsJ3nfAGvNcdKqwBceFA06PvieyWJ12mKxG5YPYp7NQTT5aqwOkRbYlJHSghSqbiBA2nSm9dee5vd4jrlt85oIjISwoKMYOOagaQBabJXW3WMlPXcZmaQu5lCQV0iUII40UYRM+f80Joa/DxAbUc0r6s+xH/6kHatfFqnBIJ1pdKScvJIEhAtGFFC+hD3EhgQ6E+S8T4DNB4zZpcmua/Hw4/eplATgBCg3XVNTgTUFlPqg8Gz3eUfcERYVjolXyW5Q2lekORAVetaH1ZCP0F3fD5Mdhq+F2Pnh8V0t7V0yXf2LnD2b5vu9BVctHDqc1dOEBQf/2lK89v7fAZkEwGQRDYgQcV3K07mhOt8Tj54a/v6VSf3bpOzbs5+HaC1r3AAuKB7g9i/j9JdCbpZKi+vsVXeUOtvd+CiwwVIWfoqFsOg/Xdw/U4VZpa3DMUHEMHdi2UKeaH1CwcHUZF1cNUWI9rOj5noAX+/dnv/+n0R1Ujczb8Atoajyo+GEL/sHMIl1CQn5zT6MEAyrUd6wX8ATj3gQFEnaMZuFFhmy/f0LLuY35jMhn0wJY0BcZQjd9FFhKggnK/8sj/oeMM282xSdVT3Ek144ShY09HKlGGOi1/mOqrqTiJ6wDUxCd0VeHKetPU8x90LG0Lju3plGHEK2Zl8D/EV5r9XB4/YQoWAcF27O2SabufwwkCTj4bPJwrqvmsGNBF4o+EaHt3MPV9BhAniCPz519m60r8Dt8YhobzQyRrNEPTBtZ286w2NtGdXFPLc7jEtGPfe7gupWG9L+qAa+AbAyHMB65a8cDbLbh+11q4IXJA1dcmfcM3OXLib/JZdbui0ergH26MBo8PrQ0kzx2YrOkTP8KiEYPv7un1ulLvCU0xIHufAfiRmp0TzFBqfkGINnQ0BasCnosPVHHp7Uy74zJm/+DPZ18vjO6bMwP+vawj1hgWpM9jRrXXfNJCHtE19mzHy+7O3rdVQ0OY098DMDsSFZqdjTx2w0pcjwHH8F9RNQ5oABgw5b2k7wRNitb/LJdS3sUFKxB/JGsB53kvL2dNnuEloibf3dsrd+5/VzFUMySepK/a2BmrPEI3WlkSlzUpD9MgDaBCcg6SOO397z+d9SVu9P4yl8GnF4fnjI/AH7ZE0s+7eT4uOsFpOukTXFNUDul7laTv5KIPXd/yzPJy6RMygzSACsIV4doLn7jdzmqbdaydKD7iVgTYN9yy8mTD1FnSNCLKju693s797/jShx9HKk7X8uD4cBmJ1N1EtK1uDT4LpOcwDWFAsCLQl9vc05SabwbCD05fwk4fdk6OTtZOsRl1s5xjJ9Sp6VzWbd/5Gtxg6AXmNzEHODrRuIqIUPyXVy27/0U4e2p4N7AU/yEMoEqaAuggrr3w0ac8J3qvGcOHuvLI0ILA8Nk8btS49cdNx9Im+LZdO7196d2KDsuP6AeI5y42g3o2rXRNjJ7gS5+tCla5UuLpuSIDqAJ7BOIii2uTr8b11h642EeEQSQCbc+RH502V1bH4tqenl6nc2eHYqpRBD88op4MH8MHCMzA0f0Xz76r27drFS5KE33DMoDU5dLb52lXLL9nl6GO+7oRQXCRdKtkCSEA/8hELm/OycjZxzQ4x0+cqGRwZf3ltztBtgM9oEsjfkzPNuO48WSZ91970eO/J00mjR4Oz2EZQB3uuAyfp9BUuOCJu5xs5H4CjEHoIsU/PNHiTZHeuvgU7+SPzMBBLmft77zldad2KIYWgTn0Tw0dUn0rre6JxqZfTkiGmjwcwgdlAHVaXZgKx9TMvdTKaLvgG1CceViODjfQ4SgnJriIZw/ksnLbrl3ua7vbVVONcxexP8BHvJc2gjqL6HVfvBKqTxpcyfCV4uLP89KCSs+hb3Db/cuWZN3dbR4uk+LaEi4TjHihshK491XmIcyNqQBFpNug9Fc0igm3QBUtn6m66fqWp5O0t0ni8nexdpiHUgDDNAmKiZs0JW69f+nlir7/f7Np/EEPsggHsSMHBfg+Kv29n7/SBUCAhWXGFcNKmQ/csPKZFVTqm6tR2KsRp0CIJ4j3l8brLnjyV04u8eNYQodL6TvbRb86bPtB5zQVSlLeiHLDSuvPz5y64rNUTt8DjNZYD4JUArTiYylXb2n95C/UaObL2RS5yn5gZdTMrAj80AqtSEwYTjbaXjtuTuNlS+/oSyab1GRyeKtfPsyYkCau4jNUv883W/72FTsb/1UsYeCaDZ0vjDmAgu03bbToopW/4RqLJlEI344miHhz84k1i5f4xNM+ZgzEEzPGpAEh9+hmaLLgWNzauvQ6qfTdAveE4S/65EEMrpoMYxzBKTARxhPWGn8Gh/4SDAjBREKh/4cjBGKR5M/ibz0E7mw4ZJjD0uPLEiE1E1dUrZT+wDF1Z37mC83JXGiow4ajzQ+JAQScNAH/SGrytj8vOytn773diDnT6MYmLluQ9SWvicwQxgA5SLiLpVJkxskrDIeTe2HF94FfcO4sfD4rpxoxOBl5h9kWWEIfYoQxy0J/LD0q3HJmpYWlippvX3fRX39AcA+VeOp7yAygziSlm/DBBS03v3n2G4mu3c9f53mZy3VTjsdNNtzCoqWZvvPDYQQuM+dSvF9Voq2GOv4eXUu8Go1O2z8pWyv3mC+a6VR2eia/72zbTV2sR7wZ9Jc0SCsoUTAT+sJweuUqCGvFjbobr1h23xZU8Rb8FYowvOU3HuPP+2JAOFapBG5/+DMT+qx950GWZ+KjhulA38RHj3s0JfpkRKn9A7nWYb9K+V1rkpHunvXLPc+6CPUzPY7rG1LuUoW5QeO1f77qgns7qV9hnYeWQMfeR/p/MfQDd9Uk7nYAAAAASUVORK5CYII=' />
                <span style='line-height:78px;'><b>Welcome on MobileDistribution Tool</b></span>
              </div>
              <p style='text-align:center'>Please follow this <a href="$url">link</a> to activate your account</p>
              <p style='text-align:center'>Regards</p>
            </body>
            </html>
          """;

          var envelope = new Envelope()
            ..recipients.add(userCreated.email)
            ..subject = 'MDT Account activation'
            ..html = htmlContent;
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

  @ApiMethod(method: 'POST', path: 'forgotPassword')
  Future<Response> userForgotPassword(PasswordRecoveryMessage message) async {
    await new Future.delayed(new Duration(milliseconds: loginDelay));
    var user = await users.findUserByEmail(message.email.toLowerCase());
    if (user != null){
      if (needRegistration && confirmationUrl != null && emailTransport != null) {
        //generate new password
        var newPassword = randomString(10);
        //reset user
        user = users.resetUser(user,newPassword);

        final token = {
          'user': user.email,
          'token': user.activationToken
        };
        var activationToken = jsonWebToken.encode(token);
        var url = '$confirmationUrl${activationToken}';

        //send re activation email with new password
        var htmlContent = """
            <html>
            <body>
              <div style='text-align: center'>
                <img src='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEAAAABOCAYAAACQYxCuAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAACXBIWXMAAAsTAAALEwEAmpwYAAADSGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS40LjAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iCiAgICAgICAgICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIgogICAgICAgICAgICB4bWxuczpleGlmPSJodHRwOi8vbnMuYWRvYmUuY29tL2V4aWYvMS4wLyI+CiAgICAgICAgIDx4bXA6TW9kaWZ5RGF0ZT4yMDE2LTAyLTI0VDIyOjAyOjAyPC94bXA6TW9kaWZ5RGF0ZT4KICAgICAgICAgPHhtcDpDcmVhdG9yVG9vbD5QaXhlbG1hdG9yIDMuNC4yPC94bXA6Q3JlYXRvclRvb2w+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgICAgIDx0aWZmOlJlc29sdXRpb25Vbml0PjI8L3RpZmY6UmVzb2x1dGlvblVuaXQ+CiAgICAgICAgIDx0aWZmOkNvbXByZXNzaW9uPjU8L3RpZmY6Q29tcHJlc3Npb24+CiAgICAgICAgIDxleGlmOlBpeGVsWERpbWVuc2lvbj44MDI8L2V4aWY6UGl4ZWxYRGltZW5zaW9uPgogICAgICAgICA8ZXhpZjpDb2xvclNwYWNlPjE8L2V4aWY6Q29sb3JTcGFjZT4KICAgICAgICAgPGV4aWY6UGl4ZWxZRGltZW5zaW9uPjk4MzwvZXhpZjpQaXhlbFlE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' />
                <span style='line-height:78px;'><b>MobileDistribution Tool</b></span>
              </div>
              <p style='text-align:center'>Please follow this <a href="$url">link</a> to re activate your account</p>
              <p style='text-align:center'>Your new password is: <b>$newPassword</b>, your can change it in your account settings </p>
              <p style='text-align:center'>Regards</p>
            </body>
            </html>
          """;

        var envelope = new Envelope()
          ..recipients.add(user.email)
          ..subject = 'MDT Account password recovery'
          ..html = htmlContent;
        try {
          await emailTransport.send(envelope);
        } catch (e) {
          throw new RpcError(
              500, 'REGISTER_ERROR', "Unable to send confirmation email");
        }

        trackUserForgotPassword(user.email);
        return new Response(200,{'message':'Your account has been desactivated, a email with new password and activation link was sent'});
      }else {
        throw new RpcError(
            400, 'REQUEST_ERROR', "Contact an administrator to retrieve new password");
      }
    }else {
      throw new NotFoundError();
    }
  }


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
        await users.updateFavoritesApp(user, message.favoritesApplicationUUID);
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

class PasswordRecoveryMessage {
  @ApiProperty(required: true)
  String email;
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