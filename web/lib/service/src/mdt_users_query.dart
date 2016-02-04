import 'package:angular/angular.dart';
import 'dart:async';
import 'dart:convert';
import 'mdt_conf_query.dart';
import '../../model/errors.dart';
import '../../model/mdt_model.dart';

abstract class MDTQueryServiceUsers{

  Future<Map> loginUser(String email, String password) async {
    String url = '${mdtServerApiRootUrl}${usersPath}/login';
    var userLogin = {"email": "$email", "password": "$password"};
    var response = await sendRequest('POST', url,
    body: 'username=${email}&password=${password}',
    contentType: 'application/x-www-form-urlencoded');
    var responseJson = parseResponse(response);

    return responseJson;
  }

  Future activateUser(String activationToken) async {
    String url = "${mdtServerApiRootUrl}${inPath}/activation";
    var data = {"activationToken" : activationToken};
    var response = await sendRequest('POST', url, body: JSON.encode(data));
    var responseJson = parseResponse(response);

    if (responseJson["error"] != null) {
      throw new ActivationError(responseJson["error"]["message"]);
    }

    if (response.status != 200){
      throw new ActivationError("Registration error, please try later or contact an administrator.");
    }
  }

  Future<Map> registerUser(String username, String email, String password) async {
    String url = "${mdtServerApiRootUrl}${usersPath}/register";
    var userRegistration = {
      "email": "$email",
      "password": "$password",
      "name": "$username"
    };
    var response =
    await sendRequest('POST', url, body: JSON.encode(userRegistration));
    var responseJson = parseResponse(response);

    if (responseJson["error"] != null) {
      throw new RegisterError(responseJson["error"]["message"]);
    }
    return responseJson;
  }
}