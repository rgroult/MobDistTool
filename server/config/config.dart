import 'dart:io';
import '../managers/src/artifacts_manager.dart';
import 'dart:async';
import 'dart:convert';

final Map defaultConfig = {
  MDT_SERVER_PORT:8080,
  MDT_SERVER_URL:"http://localhost:8080",
  MDT_DATABASE_URI:"mongodb://localhost:27017/mdt_dev",
  MDT_STORAGE_NAME:"yes_storage_manager",
  MDT_STORAGE_CONFIG:{},
  MDT_SMTP_CONFIG:{},
  MDT_REGISTRATION_WHITE_DOMAINS:[],
  MDT_REGISTRATION_NEED_ACTIVATION:false,
  MDT_TOKEN_SECRET:"secret token dsfsxfsfsqd%%Qsdqs"
};

Map<String, Object> currentLoadedConfig = defaultConfig;


final String MDT_DATABASE_URI = "MDT_DATABASE_URI";
final String MDT_STORAGE_NAME = "MDT_STORAGE_NAME";
final String MDT_STORAGE_CONFIG = "MDT_STORAGE_CONFIG";
final String MDT_SERVER_URL = "MDT_SERVER_URL";
final String MDT_SMTP_CONFIG = "MDT_SMTP_CONFIG";
final String MDT_REGISTRATION_WHITE_DOMAINS = "MDT_REGISTRATION_WHITE_DOMAINS";
final String MDT_REGISTRATION_NEED_ACTIVATION = "MDT_REGISTRATION_NEED_ACTIVATION";
final String MDT_SERVER_PORT = "MDT_SERVER_PORT";
final String MDT_TOKEN_SECRET = "MDT_TOKEN_SECRET";

Future loadConfig() async{
  //load 'config.json' file is present
  var loadedConfig = null;
  try {
    var configFileText = await new File('server/config/config.json').readAsString();
    loadedConfig = JSON.decode(configFileText);
  }catch(e){}
  if (loadedConfig != null){
    currentLoadedConfig.addAll(loadedConfig);
  }else{
    //load default config
    currentLoadedConfig.addAll(defaultConfig);
  }

  //override by env values if present
  Map<String, String> env = Platform.environment;

  if (env[MDT_TOKEN_SECRET] != null){
    currentLoadedConfig[MDT_TOKEN_SECRET] = env[MDT_TOKEN_SECRET];
  }

  if (env[MDT_SERVER_PORT] != null){
    currentLoadedConfig[MDT_SERVER_PORT] = env[MDT_SERVER_PORT];
  }
  if (env[MDT_SERVER_URL] != null){
    currentLoadedConfig[MDT_SERVER_URL] = env[MDT_SERVER_URL];
  }
  if (env[MDT_DATABASE_URI] != null){
    currentLoadedConfig[MDT_DATABASE_URI] = env[MDT_DATABASE_URI];
  }
  if (env[MDT_STORAGE_NAME] != null){
    currentLoadedConfig[MDT_STORAGE_NAME] = env[MDT_STORAGE_NAME];
  }
  if (env[MDT_STORAGE_CONFIG] != null){
    currentLoadedConfig[MDT_STORAGE_CONFIG] = JSON.decode(env[MDT_STORAGE_CONFIG]);
  }
  if (env[MDT_SMTP_CONFIG] != null){
    currentLoadedConfig[MDT_SMTP_CONFIG] = JSON.decode(env[MDT_SMTP_CONFIG]);
  }
  if (env[MDT_REGISTRATION_WHITE_DOMAINS] != null){
    currentLoadedConfig[MDT_REGISTRATION_WHITE_DOMAINS] = JSON.decode(env[MDT_REGISTRATION_WHITE_DOMAINS]);
  }
  if (env[MDT_REGISTRATION_NEED_ACTIVATION] != null){
    currentLoadedConfig[MDT_REGISTRATION_NEED_ACTIVATION] = env[MDT_REGISTRATION_NEED_ACTIVATION];
  }

  //check config
  if (currentLoadedConfig[MDT_DATABASE_URI] == null){
    throw new StateError("MDT_DATABASE_URI config not found");
  }

  if (currentLoadedConfig[MDT_STORAGE_NAME] == null){
    throw new StateError("MDT_STORAGE_NAME config not found");
  }
/*
  //mongo db
  var mongoURL = env[MDT_DATABASE_URI];
  if (mongoURL == null){
    mongoURL = "mongodb://localhost:27017/mdt_dev";
  }
  currentLoadedConfig[MDT_DATABASE_URI] = mongoURL;
  //artifact storage
*/
}
