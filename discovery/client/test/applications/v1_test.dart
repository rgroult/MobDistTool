library googleapis.applications.v1.test;

import "dart:core" as core;
import "dart:collection" as collection;
import "dart:async" as async;
import "dart:convert" as convert;

import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:unittest/unittest.dart' as unittest;

import 'package:googleapis/applications/v1.dart' as api;

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

core.int buildCounterAddAdminUserMessage = 0;
buildAddAdminUserMessage() {
  var o = new api.AddAdminUserMessage();
  buildCounterAddAdminUserMessage++;
  if (buildCounterAddAdminUserMessage < 3) {
    o.email = "foo";
  }
  buildCounterAddAdminUserMessage--;
  return o;
}

checkAddAdminUserMessage(api.AddAdminUserMessage o) {
  buildCounterAddAdminUserMessage++;
  if (buildCounterAddAdminUserMessage < 3) {
    unittest.expect(o.email, unittest.equals('foo'));
  }
  buildCounterAddAdminUserMessage--;
}

core.int buildCounterCreateApplication = 0;
buildCreateApplication() {
  var o = new api.CreateApplication();
  buildCounterCreateApplication++;
  if (buildCounterCreateApplication < 3) {
    o.description = "foo";
    o.name = "foo";
    o.platform = "foo";
  }
  buildCounterCreateApplication--;
  return o;
}

checkCreateApplication(api.CreateApplication o) {
  buildCounterCreateApplication++;
  if (buildCounterCreateApplication < 3) {
    unittest.expect(o.description, unittest.equals('foo'));
    unittest.expect(o.name, unittest.equals('foo'));
    unittest.expect(o.platform, unittest.equals('foo'));
  }
  buildCounterCreateApplication--;
}

buildUnnamed0() {
  var o = new core.Map<core.String, core.String>();
  o["x"] = "foo";
  o["y"] = "foo";
  return o;
}

checkUnnamed0(core.Map<core.String, core.String> o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o["x"], unittest.equals('foo'));
  unittest.expect(o["y"], unittest.equals('foo'));
}

core.int buildCounterResponse = 0;
buildResponse() {
  var o = new api.Response();
  buildCounterResponse++;
  if (buildCounterResponse < 3) {
    o.data = buildUnnamed0();
    o.status = 42;
  }
  buildCounterResponse--;
  return o;
}

checkResponse(api.Response o) {
  buildCounterResponse++;
  if (buildCounterResponse < 3) {
    checkUnnamed0(o.data);
    unittest.expect(o.status, unittest.equals(42));
  }
  buildCounterResponse--;
}

buildUnnamed1() {
  var o = new core.Map<core.String, core.String>();
  o["x"] = "foo";
  o["y"] = "foo";
  return o;
}

checkUnnamed1(core.Map<core.String, core.String> o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o["x"], unittest.equals('foo'));
  unittest.expect(o["y"], unittest.equals('foo'));
}

buildUnnamed2() {
  var o = new core.List<core.Map<core.String, core.String>>();
  o.add(buildUnnamed1());
  o.add(buildUnnamed1());
  return o;
}

checkUnnamed2(core.List<core.Map<core.String, core.String>> o) {
  unittest.expect(o, unittest.hasLength(2));
  checkUnnamed1(o[0]);
  checkUnnamed1(o[1]);
}

core.int buildCounterResponseList = 0;
buildResponseList() {
  var o = new api.ResponseList();
  buildCounterResponseList++;
  if (buildCounterResponseList < 3) {
    o.list = buildUnnamed2();
    o.status = 42;
  }
  buildCounterResponseList--;
  return o;
}

checkResponseList(api.ResponseList o) {
  buildCounterResponseList++;
  if (buildCounterResponseList < 3) {
    checkUnnamed2(o.list);
    unittest.expect(o.status, unittest.equals(42));
  }
  buildCounterResponseList--;
}

core.int buildCounterUpdateApplication = 0;
buildUpdateApplication() {
  var o = new api.UpdateApplication();
  buildCounterUpdateApplication++;
  if (buildCounterUpdateApplication < 3) {
    o.description = "foo";
    o.name = "foo";
    o.platform = "foo";
  }
  buildCounterUpdateApplication--;
  return o;
}

checkUpdateApplication(api.UpdateApplication o) {
  buildCounterUpdateApplication++;
  if (buildCounterUpdateApplication < 3) {
    unittest.expect(o.description, unittest.equals('foo'));
    unittest.expect(o.name, unittest.equals('foo'));
    unittest.expect(o.platform, unittest.equals('foo'));
  }
  buildCounterUpdateApplication--;
}


main() {
  unittest.group("obj-schema-AddAdminUserMessage", () {
    unittest.test("to-json--from-json", () {
      var o = buildAddAdminUserMessage();
      var od = new api.AddAdminUserMessage.fromJson(o.toJson());
      checkAddAdminUserMessage(od);
    });
  });


  unittest.group("obj-schema-CreateApplication", () {
    unittest.test("to-json--from-json", () {
      var o = buildCreateApplication();
      var od = new api.CreateApplication.fromJson(o.toJson());
      checkCreateApplication(od);
    });
  });


  unittest.group("obj-schema-Response", () {
    unittest.test("to-json--from-json", () {
      var o = buildResponse();
      var od = new api.Response.fromJson(o.toJson());
      checkResponse(od);
    });
  });


  unittest.group("obj-schema-ResponseList", () {
    unittest.test("to-json--from-json", () {
      var o = buildResponseList();
      var od = new api.ResponseList.fromJson(o.toJson());
      checkResponseList(od);
    });
  });


  unittest.group("obj-schema-UpdateApplication", () {
    unittest.test("to-json--from-json", () {
      var o = buildUpdateApplication();
      var od = new api.UpdateApplication.fromJson(o.toJson());
      checkUpdateApplication(od);
    });
  });


  unittest.group("resource-ApplicationsApi", () {
    unittest.test("method--addAdminUserApplication", () {

      var mock = new HttpServerMock();
      api.ApplicationsApi res = new api.ApplicationsApi(mock);
      var arg_request = buildAddAdminUserMessage();
      var arg_appId = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.AddAdminUserMessage.fromJson(json);
        checkAddAdminUserMessage(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("applications/v1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 4), unittest.equals("app/"));
        pathOffset += 4;
        index = path.indexOf("/adminUser", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_appId"));
        unittest.expect(path.substring(pathOffset, pathOffset + 10), unittest.equals("/adminUser"));
        pathOffset += 10;

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
      res.addAdminUserApplication(arg_request, arg_appId).then(unittest.expectAsync(((api.Response response) {
        checkResponse(response);
      })));
    });

    unittest.test("method--allApplications", () {

      var mock = new HttpServerMock();
      api.ApplicationsApi res = new api.ApplicationsApi(mock);
      var arg_platform = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("applications/v1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("search"));
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
        unittest.expect(queryMap["platform"].first, unittest.equals(arg_platform));


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildResponseList());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.allApplications(platform: arg_platform).then(unittest.expectAsync(((api.ResponseList response) {
        checkResponseList(response);
      })));
    });

    unittest.test("method--applicationDetail", () {

      var mock = new HttpServerMock();
      api.ApplicationsApi res = new api.ApplicationsApi(mock);
      var arg_appId = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("applications/v1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 4), unittest.equals("app/"));
        pathOffset += 4;
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset));
        pathOffset = path.length;
        unittest.expect(subPart, unittest.equals("$arg_appId"));

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
      res.applicationDetail(arg_appId).then(unittest.expectAsync(((api.Response response) {
        checkResponse(response);
      })));
    });

    unittest.test("method--createApplication", () {

      var mock = new HttpServerMock();
      api.ApplicationsApi res = new api.ApplicationsApi(mock);
      var arg_request = buildCreateApplication();
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.CreateApplication.fromJson(json);
        checkCreateApplication(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("applications/v1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("create"));
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
        var resp = convert.JSON.encode(buildResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.createApplication(arg_request).then(unittest.expectAsync(((api.Response response) {
        checkResponse(response);
      })));
    });

    unittest.test("method--deleteAdminUserApplication", () {

      var mock = new HttpServerMock();
      api.ApplicationsApi res = new api.ApplicationsApi(mock);
      var arg_appId = "foo";
      var arg_adminEmail = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("applications/v1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 4), unittest.equals("app/"));
        pathOffset += 4;
        index = path.indexOf("/adminUser", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_appId"));
        unittest.expect(path.substring(pathOffset, pathOffset + 10), unittest.equals("/adminUser"));
        pathOffset += 10;

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
        unittest.expect(queryMap["adminEmail"].first, unittest.equals(arg_adminEmail));


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.deleteAdminUserApplication(arg_appId, adminEmail: arg_adminEmail).then(unittest.expectAsync(((api.Response response) {
        checkResponse(response);
      })));
    });

    unittest.test("method--deleteApplication", () {

      var mock = new HttpServerMock();
      api.ApplicationsApi res = new api.ApplicationsApi(mock);
      var arg_appId = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("applications/v1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 4), unittest.equals("app/"));
        pathOffset += 4;
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset));
        pathOffset = path.length;
        unittest.expect(subPart, unittest.equals("$arg_appId"));

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
      res.deleteApplication(arg_appId).then(unittest.expectAsync(((api.Response response) {
        checkResponse(response);
      })));
    });

    unittest.test("method--getApplicationVersions", () {

      var mock = new HttpServerMock();
      api.ApplicationsApi res = new api.ApplicationsApi(mock);
      var arg_appId = "foo";
      var arg_pageIndex = 42;
      var arg_limitPerPage = 42;
      var arg_branch = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("applications/v1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 4), unittest.equals("app/"));
        pathOffset += 4;
        index = path.indexOf("/versions", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_appId"));
        unittest.expect(path.substring(pathOffset, pathOffset + 9), unittest.equals("/versions"));
        pathOffset += 9;

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
        unittest.expect(core.int.parse(queryMap["pageIndex"].first), unittest.equals(arg_pageIndex));
        unittest.expect(core.int.parse(queryMap["limitPerPage"].first), unittest.equals(arg_limitPerPage));
        unittest.expect(queryMap["branch"].first, unittest.equals(arg_branch));


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.getApplicationVersions(arg_appId, pageIndex: arg_pageIndex, limitPerPage: arg_limitPerPage, branch: arg_branch).then(unittest.expectAsync(((api.Response response) {
        checkResponse(response);
      })));
    });

    unittest.test("method--updateApplication", () {

      var mock = new HttpServerMock();
      api.ApplicationsApi res = new api.ApplicationsApi(mock);
      var arg_request = buildUpdateApplication();
      var arg_appId = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.UpdateApplication.fromJson(json);
        checkUpdateApplication(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("applications/v1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 4), unittest.equals("app/"));
        pathOffset += 4;
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset));
        pathOffset = path.length;
        unittest.expect(subPart, unittest.equals("$arg_appId"));

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
      res.updateApplication(arg_request, arg_appId).then(unittest.expectAsync(((api.Response response) {
        checkResponse(response);
      })));
    });

  });


}

