
final allErrorsMessageByCode = {
  "LOGIN_ERROR" : "Bad Login or Password",
  "BASE_ERROR" : "Base Error message",
  "REGISTER_ERROR": "Registration Error"
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

class ApplicationError extends BaseError {
  static String errorCode = "APPLICATION_ERROR";
  ApplicationError(String reason):super(errorCode,reason:reason){}
}

class ArtifactsError extends BaseError {
  static String errorCode = "ARTIFACT_ERROR";
  ArtifactsError(String reason):super(errorCode,reason:reason){}
}