// Copyright (c) 2016, Rémi Groult.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.
import 'dart:convert';
import 'utils.dart' as utils;

LiteMemCache instance = new LiteMemCache();

class LiteMemCache{
  var defaultValidity = 3600; // 1 hour
  Map<String,Map> _allValues;
  Map<String,DateTime> _expiredValuesDates;
  LiteMemCache({int defaultValidity,int clearInterval}){
    _allValues = new Map<String,Map>();
    _expiredValuesDates = new Map<String,DateTime>();
    if(defaultValidity != null){
      this.defaultValidity = defaultValidity;
    }
    if(clearInterval != null){
      _clearInterval = clearInterval;
    }
  }

  String addValue(Map value){
    var mapString =  JSON.encode(value);
    var key = utils.generateHash(mapString);
    add(key,value);
    return key;
  }

  Map get(String key){
    return _allValues[key];
  }

  void add(String key, Map value){
    _clearOldValues();
    var expiredAl = new DateTime.now()
        ..add(new Duration(seconds: defaultValidity));
    _allValues[key] = value;
    _expiredValuesDates[key] = expiredAl;
  }

  void remove(String key){
    _allValues.remove(key);
    _expiredValuesDates.remove(key);
    _clearOldValues();
  }

  DateTime _nextCleanDate;
  var _clearInterval = 60*5; // 5mins

  void _clearOldValues(){
    var now = new DateTime.now();
      if (_nextCleanDate == null || now.isAfter(_nextCleanDate)){
          var allKeys = _expiredValuesDates.keys;
          var invalidKeys = new Set<String>();
          allKeys.forEach((k) => _checkValidity(k,now,invalidKeys));
          _nextCleanDate = now.add(new Duration(seconds:_clearInterval));
          invalidKeys.forEach((k){
            _allValues.remove(k);
           _expiredValuesDates.remove(k);
          });
      }
  }

  void _checkValidity(String key, DateTime now,Set<String>invalidKeys){
    if (now.isAfter(_expiredValuesDates[key])){
      invalidKeys.add(key);
    }
  }
}