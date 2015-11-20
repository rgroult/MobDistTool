library googleapis.art.v1.test;

import "dart:core" as core;
import "dart:collection" as collection;
import "dart:async" as async;
import "dart:convert" as convert;

import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:unittest/unittest.dart' as unittest;

import 'package:googleapis/art/v1.dart' as api;

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

core.int buildCounterArtifactMsg = 0;
buildArtifactMsg() {
  var o = new api.ArtifactMsg();
  buildCounterArtifactMsg++;
  if (buildCounterArtifactMsg < 3) {
    o.artifactFile = buildMediaMessage();
    o.jsonTags = "foo";
    o.sortIdentifier = "foo";
  }
  buildCounterArtifactMsg--;
  return o;
}

checkArtifactMsg(api.ArtifactMsg o) {
  buildCounterArtifactMsg++;
  if (buildCounterArtifactMsg < 3) {
    checkMediaMessage(o.artifactFile);
    unittest.expect(o.jsonTags, unittest.equals('foo'));
    unittest.expect(o.sortIdentifier, unittest.equals('foo'));
  }
  buildCounterArtifactMsg--;
}

core.int buildCounterFullArtifactMsg = 0;
buildFullArtifactMsg() {
  var o = new api.FullArtifactMsg();
  buildCounterFullArtifactMsg++;
  if (buildCounterFullArtifactMsg < 3) {
    o.artifactFile = buildMediaMessage();
    o.artifactName = "foo";
    o.branch = "foo";
    o.jsonTags = "foo";
    o.sortIdentifier = "foo";
    o.version = "foo";
  }
  buildCounterFullArtifactMsg--;
  return o;
}

checkFullArtifactMsg(api.FullArtifactMsg o) {
  buildCounterFullArtifactMsg++;
  if (buildCounterFullArtifactMsg < 3) {
    checkMediaMessage(o.artifactFile);
    unittest.expect(o.artifactName, unittest.equals('foo'));
    unittest.expect(o.branch, unittest.equals('foo'));
    unittest.expect(o.jsonTags, unittest.equals('foo'));
    unittest.expect(o.sortIdentifier, unittest.equals('foo'));
    unittest.expect(o.version, unittest.equals('foo'));
  }
  buildCounterFullArtifactMsg--;
}

buildUnnamed3() {
  var o = new core.List<core.int>();
  o.add(42);
  o.add(42);
  return o;
}

checkUnnamed3(core.List<core.int> o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o[0], unittest.equals(42));
  unittest.expect(o[1], unittest.equals(42));
}

buildUnnamed4() {
  var o = new core.Map<core.String, core.String>();
  o["x"] = "foo";
  o["y"] = "foo";
  return o;
}

checkUnnamed4(core.Map<core.String, core.String> o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o["x"], unittest.equals('foo'));
  unittest.expect(o["y"], unittest.equals('foo'));
}

core.int buildCounterMediaMessage = 0;
buildMediaMessage() {
  var o = new api.MediaMessage();
  buildCounterMediaMessage++;
  if (buildCounterMediaMessage < 3) {
    o.bytes = buildUnnamed3();
    o.cacheControl = "foo";
    o.contentEncoding = "foo";
    o.contentLanguage = "foo";
    o.contentType = "foo";
    o.md5Hash = "foo";
    o.metadata = buildUnnamed4();
    o.updated = core.DateTime.parse("2002-02-27T14:01:02");
  }
  buildCounterMediaMessage--;
  return o;
}

checkMediaMessage(api.MediaMessage o) {
  buildCounterMediaMessage++;
  if (buildCounterMediaMessage < 3) {
    checkUnnamed3(o.bytes);
    unittest.expect(o.cacheControl, unittest.equals('foo'));
    unittest.expect(o.contentEncoding, unittest.equals('foo'));
    unittest.expect(o.contentLanguage, unittest.equals('foo'));
    unittest.expect(o.contentType, unittest.equals('foo'));
    unittest.expect(o.md5Hash, unittest.equals('foo'));
    checkUnnamed4(o.metadata);
    unittest.expect(o.updated, unittest.equals(core.DateTime.parse("2002-02-27T14:01:02")));
  }
  buildCounterMediaMessage--;
}

buildUnnamed5() {
  var o = new core.Map<core.String, core.String>();
  o["x"] = "foo";
  o["y"] = "foo";
  return o;
}

checkUnnamed5(core.Map<core.String, core.String> o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o["x"], unittest.equals('foo'));
  unittest.expect(o["y"], unittest.equals('foo'));
}

core.int buildCounterResponse = 0;
buildResponse() {
  var o = new api.Response();
  buildCounterResponse++;
  if (buildCounterResponse < 3) {
    o.data = buildUnnamed5();
    o.status = 42;
  }
  buildCounterResponse--;
  return o;
}

checkResponse(api.Response o) {
  buildCounterResponse++;
  if (buildCounterResponse < 3) {
    checkUnnamed5(o.data);
    unittest.expect(o.status, unittest.equals(42));
  }
  buildCounterResponse--;
}


main() {
  unittest.group("obj-schema-ArtifactMsg", () {
    unittest.test("to-json--from-json", () {
      var o = buildArtifactMsg();
      var od = new api.ArtifactMsg.fromJson(o.toJson());
      checkArtifactMsg(od);
    });
  });


  unittest.group("obj-schema-FullArtifactMsg", () {
    unittest.test("to-json--from-json", () {
      var o = buildFullArtifactMsg();
      var od = new api.FullArtifactMsg.fromJson(o.toJson());
      checkFullArtifactMsg(od);
    });
  });


  unittest.group("obj-schema-MediaMessage", () {
    unittest.test("to-json--from-json", () {
      var o = buildMediaMessage();
      var od = new api.MediaMessage.fromJson(o.toJson());
      checkMediaMessage(od);
    });
  });


  unittest.group("obj-schema-Response", () {
    unittest.test("to-json--from-json", () {
      var o = buildResponse();
      var od = new api.Response.fromJson(o.toJson());
      checkResponse(od);
    });
  });


  unittest.group("resource-ArtApi", () {
    unittest.test("method--addArtifact", () {

      var mock = new HttpServerMock();
      api.ArtApi res = new api.ArtApi(mock);
      var arg_request = buildFullArtifactMsg();
      var arg_idArtifact = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.FullArtifactMsg.fromJson(json);
        checkFullArtifactMsg(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 7), unittest.equals("art/v1/"));
        pathOffset += 7;
        unittest.expect(path.substring(pathOffset, pathOffset + 10), unittest.equals("artifacts/"));
        pathOffset += 10;
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset));
        pathOffset = path.length;
        unittest.expect(subPart, unittest.equals("$arg_idArtifact"));

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
      res.addArtifact(arg_request, arg_idArtifact).then(unittest.expectAsync(((api.Response response) {
        checkResponse(response);
      })));
    });

    unittest.test("method--addArtifactByAppKey", () {

      var mock = new HttpServerMock();
      api.ArtApi res = new api.ArtApi(mock);
      var arg_request = buildArtifactMsg();
      var arg_apiKey = "foo";
      var arg_branch = "foo";
      var arg_version = "foo";
      var arg_artifactName = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.ArtifactMsg.fromJson(json);
        checkArtifactMsg(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 7), unittest.equals("art/v1/"));
        pathOffset += 7;
        unittest.expect(path.substring(pathOffset, pathOffset + 10), unittest.equals("artifacts/"));
        pathOffset += 10;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_apiKey"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_branch"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_version"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset));
        pathOffset = path.length;
        unittest.expect(subPart, unittest.equals("$arg_artifactName"));

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
      res.addArtifactByAppKey(arg_request, arg_apiKey, arg_branch, arg_version, arg_artifactName).then(unittest.expectAsync(((api.Response response) {
        checkResponse(response);
      })));
    });

    unittest.test("method--addLastArtifactByAppKey", () {

      var mock = new HttpServerMock();
      api.ArtApi res = new api.ArtApi(mock);
      var arg_request = buildArtifactMsg();
      var arg_apiKey = "foo";
      var arg_artifactName = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.ArtifactMsg.fromJson(json);
        checkArtifactMsg(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 7), unittest.equals("art/v1/"));
        pathOffset += 7;
        unittest.expect(path.substring(pathOffset, pathOffset + 10), unittest.equals("artifacts/"));
        pathOffset += 10;
        index = path.indexOf("/last/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_apiKey"));
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("/last/"));
        pathOffset += 6;
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset));
        pathOffset = path.length;
        unittest.expect(subPart, unittest.equals("$arg_artifactName"));

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
      res.addLastArtifactByAppKey(arg_request, arg_apiKey, arg_artifactName).then(unittest.expectAsync(((api.Response response) {
        checkResponse(response);
      })));
    });

    unittest.test("method--deleteArtifact", () {

      var mock = new HttpServerMock();
      api.ArtApi res = new api.ArtApi(mock);
      var arg_idArtifact = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 7), unittest.equals("art/v1/"));
        pathOffset += 7;
        unittest.expect(path.substring(pathOffset, pathOffset + 10), unittest.equals("artifacts/"));
        pathOffset += 10;
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset));
        pathOffset = path.length;
        unittest.expect(subPart, unittest.equals("$arg_idArtifact"));

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
      res.deleteArtifact(arg_idArtifact).then(unittest.expectAsync(((api.Response response) {
        checkResponse(response);
      })));
    });

    unittest.test("method--deleteArtifactByAppKey", () {

      var mock = new HttpServerMock();
      api.ArtApi res = new api.ArtApi(mock);
      var arg_apiKey = "foo";
      var arg_branch = "foo";
      var arg_version = "foo";
      var arg_artifactName = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 7), unittest.equals("art/v1/"));
        pathOffset += 7;
        unittest.expect(path.substring(pathOffset, pathOffset + 10), unittest.equals("artifacts/"));
        pathOffset += 10;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_apiKey"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_branch"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_version"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset));
        pathOffset = path.length;
        unittest.expect(subPart, unittest.equals("$arg_artifactName"));

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
      res.deleteArtifactByAppKey(arg_apiKey, arg_branch, arg_version, arg_artifactName).then(unittest.expectAsync(((api.Response response) {
        checkResponse(response);
      })));
    });

    unittest.test("method--deleteLastArtifactByAppKey", () {

      var mock = new HttpServerMock();
      api.ArtApi res = new api.ArtApi(mock);
      var arg_apiKey = "foo";
      var arg_artifactName = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 7), unittest.equals("art/v1/"));
        pathOffset += 7;
        unittest.expect(path.substring(pathOffset, pathOffset + 10), unittest.equals("artifacts/"));
        pathOffset += 10;
        index = path.indexOf("/last/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_apiKey"));
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("/last/"));
        pathOffset += 6;
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset));
        pathOffset = path.length;
        unittest.expect(subPart, unittest.equals("$arg_artifactName"));

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
      res.deleteLastArtifactByAppKey(arg_apiKey, arg_artifactName).then(unittest.expectAsync(((api.Response response) {
        checkResponse(response);
      })));
    });

  });


}

