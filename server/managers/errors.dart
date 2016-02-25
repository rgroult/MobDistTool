// Copyright (c) 2016, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'package:rpc/rpc.dart';

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
