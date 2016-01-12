import 'package:rpc/rpc.dart';

class MDTError extends RpcError {

}

class UserAuthenticationError extends RpcError {
  UserAuthenticationError([String message = "User Not Found."])
  : super(401, 'Authentication Failed.', message);
}

class AppError extends StateError {
  AppError(String msg) : super(msg);
}

class ArtifactError extends StateError {
  ArtifactError(String msg) : super(msg);
}

class UserError extends StateError {
  UserError(String msg) : super(msg);
}
