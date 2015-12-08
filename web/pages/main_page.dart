import 'package:angular/angular.dart';
import 'package:angular_ui/angular_ui.dart';
import 'dart:convert';
import 'dart:html';


@Component(
  selector: 'register_comp',
  templateUrl: 'Users/register.html',
  exportExpressions: const ["registerUser", "displayRegisterPopup"],
  useShadowDom: false
)
class RegisterComponent implements ScopeAware {
  String username;
  String email;
  String password;
  MainComponent mainComp;
  String backdrop = 'true';

  void registerUser(String email, String password,String username) async {
    String url = "${mdtServerUrl}/api/users/v1/register";
    var userRegistration = {"email":"$email", "password":"$password", "name":"$username"};
    var response =  await mainComp.sendRequest(_http,'POST', url, body:JSON.encode(userRegistration));
    if (response.status == 200){
      querySelector('#registerModal').setAttribute('modal','hide');
    }else{
      displayErrorFromResponse(response);
    }
    print("response ${response}");

  }

  RegisterComponent(this.mainComp){
    print("RegisterComponent created");
  }
  Scope scope;
/*
  ModalInstance getModalInstance() {
    return modal.open(new ModalOptions(template:template, backdrop: backdrop), scope);
  }*/


}

@Component(
    selector: 'main_comp',
    templateUrl: 'main_page.html',
    useShadowDom: false)
class MainComponent implements ScopeAware {
  String mdtServerUrl = "http://localhost:8080";
  String email;
  String username;
  String password;
  final Http _http;
  var lastAuthorizationHeader = '';

  Modal modal;
  ModalInstance modalInstance;
  Scope scope;
  String backdrop = 'true';

  void displayRegisterPopup(){

  modalInstance = modal.open(new ModalOptions(template:"<register_comp></register_comp>", backdrop: backdrop), scope);
   // modalInstance = modal.open(new ModalOptions(templateUrl:'pages/Users/register.html', backdrop: backdrop), scope);
  }


  Map allHeaders({String contentType}){
    var requestContentType = contentType!=null ? contentType : 'application/json; charset=utf-8';
    var initialHeaders = {"content-type": requestContentType,"accept":'application/json'};
    if (lastAuthorizationHeader.length > 0){
      initialHeaders['authorization'] = lastAuthorizationHeader;
    }else {
      initialHeaders.remove('authorization');
    }
    return initialHeaders;
  }

  MainComponent(this._http,this.modal){
    print("Main component created $this");
  }

  displayErrorFromResponse(HttpResponse response){

  }

  login() async{
    print("login : $username , password $password");
    await loginUser(username,password);
  }

  register() async{
    await registerUser(email,password,username);
  }

  void registerUser(String email, String password,String username) async {
    String url = "${mdtServerUrl}/api/users/v1/register";
    var userRegistration = {"email":"$email", "password":"$password", "name":"$username"};
    var response =  await sendRequest(_http,'POST', url, body:JSON.encode(userRegistration));
    if (response.status == 200){
      querySelector('#registerModal').setAttribute('modal','hide');
    }else{
      displayErrorFromResponse(response);
    }
    print("response ${response}");

  }

  void loginUser(String email, String password) async{
    print("log user $email, $password");

    var response =  await sendRequest(_http,'POST', '${mdtServerUrl}/api/users/v1/login', body:'username=${email}&password=${password}', contentType:'application/x-www-form-urlencoded');
    print("response ${response.body}");
  }

  Future<http.Response> sendRequest(Http http,String method, String url, {String query, String body,String contentType}) {
    //var url = '$baseUrlHost$path';
    if (query != null){
      url = '$url$query';
    }
    var headers = contentType == null? allHeaders(): allHeaders(contentType:contentType);
    var httpBody = body;
    if (body ==null) {
      httpBody ='';
    }
    switch (method) {
      case 'GET':
        return http.get(url,headers:allHeaders(contentType:contentType));
      case 'POST':
        return http.post(url,httpBody,headers:headers);
      case 'PUT':
        return http.put(url,httpBody,headers:headers);
      case 'DELETE':
        return http.delete(url,headers:headers);
    }
    return null;
  }
}
