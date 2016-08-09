// Copyright (c) 2016, the Mobile App Distribution Tool project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:async';
import 'dart:convert';

final Map defaultConfig = {
  MDT_SERVER_PORT:8080,
  MDT_SERVER_URL:"http://localhost:8080",
  MDT_DATABASE_URI:"mongodb://localhost:27017/mdt_rewrite_dev",
  MDT_STORAGE_NAME:"yes_storage_manager",
  MDT_STORAGE_CONFIG:{},
  MDT_SMTP_CONFIG:{},
  MDT_REGISTRATION_WHITE_DOMAINS:[],
  MDT_REGISTRATION_NEED_ACTIVATION:"false",
  MDT_TOKEN_SECRET:"secret token dsfsxfsfsqd%%Qsdqs",
  MDT_LOG_DIR:"",
  MDT_LOG_TO_CONSOLE:"true",
  MDT_SYSADMIN_INITIAL_PASSWORD:"sysadmin",
  MDT_SYSADMIN_INITIAL_EMAIL:"admin@localhost.com",
  //delay (in ms) before login resquest response (limit brut attack).
  MDT_LOGIN_DELAY:"0",
  // minimum strength password required
  //[0,1,2,3,4] if crack time is less than
  /// [10**2, 10**4, 10**6, 10**8, Infinity]. see https://github.com/exitlive/xcvbnm for more details
  MDT_PASSWORD_MIN_STRENGTH:"0"
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
final String MDT_LOG_DIR = "MDT_LOG_DIR";
final String MDT_SYSADMIN_INITIAL_PASSWORD = "MDT_SYSADMIN_INITIAL_PASSWORD";
final String MDT_SYSADMIN_INITIAL_EMAIL = "MDT_SYSADMIN_INITIAL_EMAIL";
final String MDT_LOG_TO_CONSOLE = "MDT_LOG_TO_CONSOLE";
final String MDT_LOGIN_DELAY = "MDT_LOGIN_DELAY";
final String MDT_PASSWORD_MIN_STRENGTH = "MDT_PASSWORD_MIN_STRENGTH";

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

  if (env[MDT_LOG_TO_CONSOLE] != null){
    currentLoadedConfig[MDT_LOG_TO_CONSOLE] = env[MDT_LOG_TO_CONSOLE];
  }
  if (env[MDT_SYSADMIN_INITIAL_PASSWORD] != null){
    currentLoadedConfig[MDT_SYSADMIN_INITIAL_PASSWORD] = env[MDT_SYSADMIN_INITIAL_PASSWORD];
  }
  if (env[MDT_LOGIN_DELAY] != null){
    currentLoadedConfig[MDT_LOGIN_DELAY] = env[MDT_LOGIN_DELAY];
  }
  if (env[MDT_SYSADMIN_INITIAL_EMAIL] != null){
    currentLoadedConfig[MDT_SYSADMIN_INITIAL_EMAIL] = env[MDT_SYSADMIN_INITIAL_EMAIL];
  }
  if (env[MDT_PASSWORD_MIN_STRENGTH] != null){
    currentLoadedConfig[MDT_PASSWORD_MIN_STRENGTH] = env[MDT_PASSWORD_MIN_STRENGTH];
  }
  if (env[MDT_LOG_DIR] != null){
    currentLoadedConfig[MDT_LOG_DIR] = env[MDT_LOG_DIR];
  }

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
}
