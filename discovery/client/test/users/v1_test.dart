library googleapis.users.v1.test;

import "dart:core" as core;
import "dart:collection" as collection;
import "dart:async" as async;
import "dart:convert" as convert;

import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:unittest/unittest.dart' as unittest;

import 'package:googleapis/users/v1.dart' as api;

class HttpServerMock extends http.BaseClient {
  core.Function _callback;
  core.bool _expectJson;

  void register(core.Function callback, core.bool expectJson) {
    _callback = callback;
    _expectJson = expectJson;
  }

  async.Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (_expectJson) {
      return request.finalize()
          .transform(convert.UTF8.decoder)
          .join('')
          .then((core.String jsonString) {
        if (jsonString.isEmpty) {
          return _callback(request, null);
        } else {
          return _callback(request, convert.JSON.decode(jsonString));
        }
      });
    } else {
      var stream = request.finalize();
      if (stream == null) {
        return _callback(request, []);
      } else {
        return stream.toBytes().then((data) {
          return _callback(request, data);
        });
      }
    }
  }
}

http.StreamedResponse stringResponse(
    core.int status, core.Map headers, core.String body) {
  var stream = new async.Stream.fromIterable([convert.UTF8.encode(body)]);
  return new http.StreamedResponse(stream, status, headers: headers);
}

core.int buildCounterRegisterMessage = 0;
buildRegisterMessage() {
  var o = new api.RegisterMessage();
  buildCounterRegisterMessage++;
  if (buildCounterRegisterMessage < 3) {
    o.email = "foo";
    o.name = "foo";
    o.password = "foo";
  }
  buildCounterRegisterMessage--;
  return o;
}

checkRegisterMessage(api.RegisterMessage o) {
  buildCounterRegisterMessage++;
  if (buildCounterRegisterMessage < 3) {
    unittest.expect(o.email, unittest.equals('foo'));
    unittest.expect(o.name, unittest.equals('foo'));
    unittest.expect(o.password, unittest.equals('foo'));
  }
  buildCounterRegisterMessage--;
}

buildUnnamed6() {
  var o = new core.Map<core.String, core.String>();
  o["x"] = "foo";
  o["y"] = "foo";
  return o;
}

checkUnnamed6(core.Map<core.String, core.String> o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o["x"], unittest.equals('foo'));
  unittest.expect(o["y"], unittest.equals('foo'));
}

core.int buildCounterResponse = 0;
buildResponse() {
  var o = new api.Response();
  buildCounterResponse++;
  if (buildCounterResponse < 3) {
    o.data = buildUnnamed6();
    o.status = 42;
  }
  buildCounterResponse--;
  return o;
}

checkResponse(api.Response o) {
  buildCounterResponse++;
  if (buildCounterResponse < 3) {
    checkUnnamed6(o.data);
    unittest.expect(o.status, unittest.equals(42));
  }
  buildCounterResponse--;
}


main() {
  unittest.group("obj-schema-RegisterMessage", () {
    unittest.test("to-json--from-json", () {
      var o = buildRegisterMessage();
      var od = new api.RegisterMessage.fromJson(o.toJson());
      checkRegisterMessage(od);
    });
  });


  unittest.group("obj-schema-Response", () {
    unittest.test("to-json--from-json", () {
      var o = buildResponse();
      var od = new api.Response.fromJson(o.toJson());
      checkResponse(od);
    });
  });


  unittest.group("resource-UsersApi", () {
    unittest.test("method--userGetLogin", () {

      var mock = new HttpServerMock();
      api.UsersApi res = new api.UsersApi(mock);
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 9), unittest.equals("users/v1/"));
        pathOffset += 9;
        unittest.expect(path.substring(pathOffset, pathOffset + 5), unittest.equals("login"));
        pathOffset += 5;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.userGetLogin().then(unittest.expectAsync(((api.Response response) {
        checkResponse(response);
      })));
    });

    unittest.test("method--userLgout", () {

      var mock = new HttpServerMock();
      api.UsersApi res = new api.UsersApi(mock);
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 9), unittest.equals("users/v1/"));
        pathOffset += 9;
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("logout"));
        pathOffset += 6;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = "";
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.userLgout().then(unittest.expectAsync((_) {}));
    });

    unittest.test("method--userMe", () {

      var mock = new HttpServerMock();
      api.UsersApi res = new api.UsersApi(mock);
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 9), unittest.equals("users/v1/"));
        pathOffset += 9;
        unittest.expect(path.substring(pathOffset, pathOffset + 2), unittest.equals("me"));
        pathOffset += 2;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.userMe().then(unittest.expectAsync(((api.Response response) {
        checkResponse(response);
      })));
    });

    unittest.test("method--userPostLogin", () {

      var mock = new HttpServerMock();
      api.UsersApi res = new api.UsersApi(mock);
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 9), unittest.equals("users/v1/"));
        pathOffset += 9;
        unittest.expect(path.substring(pathOffset, pathOffset + 5), unittest.equals("login"));
        pathOffset += 5;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.userPostLogin().then(unittest.expectAsync(((api.Response response) {
        checkResponse(response);
      })));
    });

    unittest.test("method--userRegister", () {

      var mock = new HttpServerMock();
      api.UsersApi res = new api.UsersApi(mock);
      var arg_request = buildRegisterMessage();
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.RegisterMessage.fromJson(json);
        checkRegisterMessage(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 9), unittest.equals("users/v1/"));
        pathOffset += 9;
        unittest.expect(path.substring(pathOffset, pathOffset + 8), unittest.equals("register"));
        pathOffset += 8;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.userRegister(arg_request).then(unittest.expectAsync(((api.Response response) {
        checkResponse(response);
      })));
    });

  });


}

