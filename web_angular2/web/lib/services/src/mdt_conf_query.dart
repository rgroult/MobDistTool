import 'dart:core';

String mdtServerApiRootUrl = const String.fromEnvironment('mode') == 'javascript' ? "/api" : "http://localhost:8080/api";
final String appVersion = "v1";
final String appPath = "/applications/${appVersion}";
final String artifactsPath = "/art/${appVersion}";
final String inPath = "/in/${appVersion}";
final String usersPath = "/users/${appVersion}";

