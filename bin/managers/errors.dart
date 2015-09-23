import "package:rpc/rpc.dart";

class MDTError extends RpcError {

}

class UserAuthenticationError extends MDTError {
  UserAuthenticationError([String message = "User Not Found."])
  : super(401, 'Authentication Failed.', message);
}