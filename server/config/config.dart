import 'dart:io';
import '../managers/src/artifacts_manager.dart';
import 'dart:async';
import 'dart:convert';

final Map defaultConfig = {
  "MDT_DATABASE_URI":"mongodb://localhost:27017/mdt_dev",
  "MDT_STORAGE_NAME":"yes_storage_manager",
  "MDT_STORAGE_CONFIG":{}
};

Map<String, Object> currentLoadedConfig = new Map<String, Object>();


final String MDT_DATABASE_URI = "MDT_DATABASE_URI";
final String MDT_STORAGE_NAME = "MDT_STORAGE_NAME";
final String MDT_STORAGE_CONFIG = "MDT_STORAGE_CONFIG";

Future loadConfig() async{
  //load 'config.json' file is presentx
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
  if (env[MDT_DATABASE_URI] != null){
    currentLoadedConfig[MDT_DATABASE_URI] = env[MDT_DATABASE_URI];
  }
  if (env[MDT_STORAGE_NAME] != null){
    currentLoadedConfig[MDT_STORAGE_NAME] = env[MDT_STORAGE_NAME];
  }
  if (env[MDT_STORAGE_CONFIG] != null){
    currentLoadedConfig[MDT_STORAGE_CONFIG] = JSON.decode(env[MDT_STORAGE_CONFIG]);
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
