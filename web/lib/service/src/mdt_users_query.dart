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
    var responseJson = parseResponse(response,checkAuthorization:false);

    return responseJson;
  }

  Future activateUser(String activationToken) async {
    String url = "${mdtServerApiRootUrl}${inPath}/activation";
    var data = {"activationToken" : activationToken};
    var response = await sendRequest('POST', url, body: JSON.encode(data));

    if (response.status == 200){
      return;
    }

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

  Future<UserListResponse> listUsers(int pageIndex, int maxResult) async{
    String url = "${mdtServerApiRootUrl}${usersPath}/all?pageIndex=${pageIndex}&maxResult=${maxResult}";
    var response = await sendRequest('GET', url);
    var responseJson = parseResponse(response);

    if (responseJson["error"] != null) {
      throw new UsersError(responseJson["error"]["message"]);
    }

    var result = new UserListResponse();
    result.hasMore = responseJson["hasMore"];
    result.pageIndex = responseJson["pageIndex"];

    var usersList = responseJson["list"];
    if (usersList != null) {
      for (Map user in usersList) {
        var userCreated = new MDTUser(user);
        result.users.add(userCreated);
      }
    }
    return result;
  }

  Future<MDTUser> updateUser(String email, {String username, String password, bool isAdmin, bool isActivated}) async {
    String url = "${mdtServerApiRootUrl}${usersPath}/user";
    var requestData ={"email":email};
    if (password != null){
      requestData["password"] = password;
    }
    if (username != null){
      requestData["name"] = username;
    }

    if (isAdmin != null){
      requestData["sysadmin"] = isAdmin;
    }
    if (isActivated != null){
      requestData["activated"] = isActivated;
    }

    var response = await sendRequest(
        'PUT', url,
        body: JSON.encode(requestData));
    var responseJson = parseResponse(response);

    if (responseJson["error"] != null) {
      throw new UsersError(responseJson["error"]["message"]);
    }

    var userCreated = new MDTUser(responseJson["data"]);

    return userCreated;
  }

  Future<Map> deleteUser(String email) async {
    String url = "${mdtServerApiRootUrl}${usersPath}/user?email=$email";

    var response = await sendRequest( 'DELETE', url);
    var responseJson = parseResponse(response);

    if (responseJson["error"] != null) {
      throw new UsersError(responseJson["error"]["message"]);
    }
    return true;
  }
}