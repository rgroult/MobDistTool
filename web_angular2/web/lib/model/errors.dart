
final allErrorsMessageByCode = {
  "LOGIN_ERROR" : "Bad Login or Password",
  "BASE_ERROR" : "Base Error message",
  "REGISTER_ERROR": "Registration Error",
  "ACTIVATION_ERROR": "Activation Error",
  "REQUEST_ERROR": "Network request Error"
};

class BaseError extends StateError {
  static String errorCode = "BASE_ERROR";
  static String generateErrorMessage(String code,{String reason}){
    var message = allErrorsMessageByCode[code];
    if (reason != null){
      message = "$message. Reason: $reason";
    }
    return message;
  }

  BaseError(String code,{String reason}):super(generateErrorMessage(code,reason:reason)){

   // print("error ${this.toString()}, expectedd ${allErrorsMessageByCode[errorCode]}");
  }
 // String toString() => "Error: $message";
}

class ConnectionError extends BaseError {
  static String errorCode = "REQUEST_ERROR";
  ConnectionError():super(errorCode,reason:"Something were wrong on request, verify that your server is online and you are connected to Internet !" ){}
}

class LoginError extends BaseError {
  static String errorCode = "LOGIN_ERROR";
  LoginError():super(errorCode){}
}

class RegisterError extends BaseError {
  static String errorCode = "REGISTER_ERROR";
  //String reason;

  RegisterError(String reason):super(errorCode,reason:reason) {
  }
}

class UsersError extends BaseError {
static String errorCode = "USERS_ERROR";
//String reason;

  UsersError(String reason):super(errorCode,reason:reason) {
}
}

class ActivationError extends BaseError {
  static String errorCode = "ACTIVATION_ERROR";
  ActivationError(String reason):super(errorCode,reason:reason){}
}

class ApplicationError extends BaseError {
  static String errorCode = "APPLICATION_ERROR";
  ApplicationError(String reason):super(errorCode,reason:reason){}
}

class ArtifactsError extends BaseError {
  static String errorCode = "ARTIFACT_ERROR";
  ArtifactsError(String reason):super(errorCode,reason:reason){}
}