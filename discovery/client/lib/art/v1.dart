// This is a generated file (see the discoveryapis_generator project).

library googleapis.art.v1;

import 'dart:core' as core;
import 'dart:async' as async;
import 'dart:convert' as convert;

import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as commons;
import 'package:http/http.dart' as http;

export 'package:_discoveryapis_commons/_discoveryapis_commons.dart' show
    ApiRequestError, DetailedApiRequestError;

const core.String USER_AGENT = 'dart-api-client art/v1';

class ArtApi {

  final commons.ApiRequester _requester;

  ArtApi(http.Client client, {core.String rootUrl: "http://localhost:8080/", core.String servicePath: "art/v1/"}) :
      _requester = new commons.ApiRequester(client, rootUrl, servicePath, USER_AGENT);

  /**
   * [request] - The metadata request object.
   *
   * Request parameters:
   *
   * [idArtifact] - Path parameter: 'idArtifact'.
   *
   * Completes with a [Response].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<Response> addArtifact(FullArtifactMsg request, core.String idArtifact) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }
    if (idArtifact == null) {
      throw new core.ArgumentError("Parameter idArtifact is required.");
    }

    _url = 'artifacts/' + commons.Escaper.ecapeVariable('$idArtifact');

    var _response = _requester.request(_url,
                                       "PUT",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new Response.fromJson(data));
  }

  /**
   * [request] - The metadata request object.
   *
   * Request parameters:
   *
   * [apiKey] - Path parameter: 'apiKey'.
   *
   * [branch] - Path parameter: 'branch'.
   *
   * [version] - Path parameter: 'version'.
   *
   * [artifactName] - Path parameter: 'artifactName'.
   *
   * Completes with a [Response].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<Response> addArtifactByAppKey(ArtifactMsg request, core.String apiKey, core.String branch, core.String version, core.String artifactName) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }
    if (apiKey == null) {
      throw new core.ArgumentError("Parameter apiKey is required.");
    }
    if (branch == null) {
      throw new core.ArgumentError("Parameter branch is required.");
    }
    if (version == null) {
      throw new core.ArgumentError("Parameter version is required.");
    }
    if (artifactName == null) {
      throw new core.ArgumentError("Parameter artifactName is required.");
    }

    _url = 'artifacts/' + commons.Escaper.ecapeVariable('$apiKey') + '/' + commons.Escaper.ecapeVariable('$branch') + '/' + commons.Escaper.ecapeVariable('$version') + '/' + commons.Escaper.ecapeVariable('$artifactName');

    var _response = _requester.request(_url,
                                       "POST",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new Response.fromJson(data));
  }

  /**
   * [request] - The metadata request object.
   *
   * Request parameters:
   *
   * [apiKey] - Path parameter: 'apiKey'.
   *
   * [artifactName] - Path parameter: 'artifactName'.
   *
   * Completes with a [Response].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<Response> addLastArtifactByAppKey(ArtifactMsg request, core.String apiKey, core.String artifactName) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }
    if (apiKey == null) {
      throw new core.ArgumentError("Parameter apiKey is required.");
    }
    if (artifactName == null) {
      throw new core.ArgumentError("Parameter artifactName is required.");
    }

    _url = 'artifacts/' + commons.Escaper.ecapeVariable('$apiKey') + '/last/' + commons.Escaper.ecapeVariable('$artifactName');

    var _response = _requester.request(_url,
                                       "POST",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new Response.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * [idArtifact] - Path parameter: 'idArtifact'.
   *
   * Completes with a [Response].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<Response> deleteArtifact(core.String idArtifact) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (idArtifact == null) {
      throw new core.ArgumentError("Parameter idArtifact is required.");
    }

    _url = 'artifacts/' + commons.Escaper.ecapeVariable('$idArtifact');

    var _response = _requester.request(_url,
                                       "DELETE",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new Response.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * [apiKey] - Path parameter: 'apiKey'.
   *
   * [branch] - Path parameter: 'branch'.
   *
   * [version] - Path parameter: 'version'.
   *
   * [artifactName] - Path parameter: 'artifactName'.
   *
   * Completes with a [Response].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<Response> deleteArtifactByAppKey(core.String apiKey, core.String branch, core.String version, core.String artifactName) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (apiKey == null) {
      throw new core.ArgumentError("Parameter apiKey is required.");
    }
    if (branch == null) {
      throw new core.ArgumentError("Parameter branch is required.");
    }
    if (version == null) {
      throw new core.ArgumentError("Parameter version is required.");
    }
    if (artifactName == null) {
      throw new core.ArgumentError("Parameter artifactName is required.");
    }

    _url = 'artifacts/' + commons.Escaper.ecapeVariable('$apiKey') + '/' + commons.Escaper.ecapeVariable('$branch') + '/' + commons.Escaper.ecapeVariable('$version') + '/' + commons.Escaper.ecapeVariable('$artifactName');

    var _response = _requester.request(_url,
                                       "DELETE",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new Response.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * [apiKey] - Path parameter: 'apiKey'.
   *
   * [artifactName] - Path parameter: 'artifactName'.
   *
   * Completes with a [Response].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<Response> deleteLastArtifactByAppKey(core.String apiKey, core.String artifactName) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (apiKey == null) {
      throw new core.ArgumentError("Parameter apiKey is required.");
    }
    if (artifactName == null) {
      throw new core.ArgumentError("Parameter artifactName is required.");
    }

    _url = 'artifacts/' + commons.Escaper.ecapeVariable('$apiKey') + '/last/' + commons.Escaper.ecapeVariable('$artifactName');

    var _response = _requester.request(_url,
                                       "DELETE",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new Response.fromJson(data));
  }

}



class ArtifactMsg {
  MediaMessage artifactFile;
  core.String jsonTags;
  core.String sortIdentifier;

  ArtifactMsg();

  ArtifactMsg.fromJson(core.Map _json) {
    if (_json.containsKey("artifactFile")) {
      artifactFile = new MediaMessage.fromJson(_json["artifactFile"]);
    }
    if (_json.containsKey("jsonTags")) {
      jsonTags = _json["jsonTags"];
    }
    if (_json.containsKey("sortIdentifier")) {
      sortIdentifier = _json["sortIdentifier"];
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (artifactFile != null) {
      _json["artifactFile"] = (artifactFile).toJson();
    }
    if (jsonTags != null) {
      _json["jsonTags"] = jsonTags;
    }
    if (sortIdentifier != null) {
      _json["sortIdentifier"] = sortIdentifier;
    }
    return _json;
  }
}

class FullArtifactMsg {
  MediaMessage artifactFile;
  core.String artifactName;
  core.String branch;
  core.String jsonTags;
  core.String sortIdentifier;
  core.String version;

  FullArtifactMsg();

  FullArtifactMsg.fromJson(core.Map _json) {
    if (_json.containsKey("artifactFile")) {
      artifactFile = new MediaMessage.fromJson(_json["artifactFile"]);
    }
    if (_json.containsKey("artifactName")) {
      artifactName = _json["artifactName"];
    }
    if (_json.containsKey("branch")) {
      branch = _json["branch"];
    }
    if (_json.containsKey("jsonTags")) {
      jsonTags = _json["jsonTags"];
    }
    if (_json.containsKey("sortIdentifier")) {
      sortIdentifier = _json["sortIdentifier"];
    }
    if (_json.containsKey("version")) {
      version = _json["version"];
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (artifactFile != null) {
      _json["artifactFile"] = (artifactFile).toJson();
    }
    if (artifactName != null) {
      _json["artifactName"] = artifactName;
    }
    if (branch != null) {
      _json["branch"] = branch;
    }
    if (jsonTags != null) {
      _json["jsonTags"] = jsonTags;
    }
    if (sortIdentifier != null) {
      _json["sortIdentifier"] = sortIdentifier;
    }
    if (version != null) {
      _json["version"] = version;
    }
    return _json;
  }
}

class MediaMessage {
  core.List<core.int> bytes;
  core.String cacheControl;
  core.String contentEncoding;
  core.String contentLanguage;
  core.String contentType;
  core.String md5Hash;
  core.Map<core.String, core.String> metadata;
  core.DateTime updated;

  MediaMessage();

  MediaMessage.fromJson(core.Map _json) {
    if (_json.containsKey("bytes")) {
      bytes = _json["bytes"];
    }
    if (_json.containsKey("cacheControl")) {
      cacheControl = _json["cacheControl"];
    }
    if (_json.containsKey("contentEncoding")) {
      contentEncoding = _json["contentEncoding"];
    }
    if (_json.containsKey("contentLanguage")) {
      contentLanguage = _json["contentLanguage"];
    }
    if (_json.containsKey("contentType")) {
      contentType = _json["contentType"];
    }
    if (_json.containsKey("md5Hash")) {
      md5Hash = _json["md5Hash"];
    }
    if (_json.containsKey("metadata")) {
      metadata = _json["metadata"];
    }
    if (_json.containsKey("updated")) {
      updated = core.DateTime.parse(_json["updated"]);
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (bytes != null) {
      _json["bytes"] = bytes;
    }
    if (cacheControl != null) {
      _json["cacheControl"] = cacheControl;
    }
    if (contentEncoding != null) {
      _json["contentEncoding"] = contentEncoding;
    }
    if (contentLanguage != null) {
      _json["contentLanguage"] = contentLanguage;
    }
    if (contentType != null) {
      _json["contentType"] = contentType;
    }
    if (md5Hash != null) {
      _json["md5Hash"] = md5Hash;
    }
    if (metadata != null) {
      _json["metadata"] = metadata;
    }
    if (updated != null) {
      _json["updated"] = (updated).toIso8601String();
    }
    return _json;
  }
}

class Response {
  core.Map<core.String, core.String> data;
  core.int status;

  Response();

  Response.fromJson(core.Map _json) {
    if (_json.containsKey("data")) {
      data = _json["data"];
    }
    if (_json.containsKey("status")) {
      status = _json["status"];
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (data != null) {
      _json["data"] = data;
    }
    if (status != null) {
      _json["status"] = status;
    }
    return _json;
  }
}
