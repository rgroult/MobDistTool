// Copyright (c) 2016, Rémi Groult.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.
import 'package:test/test.dart';
import 'dart:async';
import '../../server/utils/lite_mem_cache.dart' as memCache;
void main() {
  allTests();
}

void allTests()  {
  var cache;
  var value ={"hello":"world"};

  test("init", () async {
    cache = new memCache.LiteMemCache(defaultValidity: 5,clearInterval: 2);
  });

  test("Simple Add, remove , get", () {
      cache.add("test",value);

      var returnValue = cache.get("test");
      expect(value,equals(returnValue));

      var key = cache.addValue(value);
      returnValue = cache.get(key);
      expect(value,equals(returnValue));

      cache.remove("test");
      cache.remove(key);
      expect(cache.get("test"),isNull);
      expect(cache.get(key),isNull);
  });

  test("Timeout test",() async{
    var key = cache.addValue(value);
    //wait 6secs
    await new Future.delayed(new Duration(seconds: 6));
    //clear is only on add and remove
    cache.add("test",value);
    expect(cache.get(key),isNull);
  });

  test("Timeout override",() {
    var newValue = value;
    var key = cache.addValue(value);
    newValue["test"] = "world";
    cache.add(key,newValue);
    expect(newValue,equals(cache.get(key)));
  });
}