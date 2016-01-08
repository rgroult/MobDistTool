import '../../../packages/angular/angular.dart';

final allErrorsMessageByCode = {
  "LOGIN_ERROR" : "Bad Login or Password",
  "BASE_ERROR" : "Base Error message",
  "REGISTER_ERROR": "Registration Error"
};

class BaseError extends StateError {
  static String errorCode = "BASE_ERROR";

  BaseError(String code):super(allErrorsMessageByCode[code]){

   // print("error ${this.toString()}, expectedd ${allErrorsMessageByCode[errorCode]}");
  }
  String toString() => "Error: $message";
}

class LoginError extends BaseError {
  static String errorCode = "LOGIN_ERROR";
  LoginError():super(errorCode){}
}

class RegisterError extends BaseError {
  static String errorCode = "REGISTER_ERROR";
  String reason;

  RegisterError(this.reason):super(errorCode) {
  }
  String toString() => "$message. Reason: $reason";
}

class CreateApplicationError extends BaseError {
  static String errorCode = "CREATE_APPLICATION_ERROR";
  CreateApplicationError():super(errorCode){}
}