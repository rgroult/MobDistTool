// This is a generated file (see the discoveryapis_generator project).

library googleapis.applications.v1;

import 'dart:core' as core;
import 'dart:async' as async;
import 'dart:convert' as convert;

import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as commons;
import 'package:http/http.dart' as http;

export 'package:_discoveryapis_commons/_discoveryapis_commons.dart' show
    ApiRequestError, DetailedApiRequestError;

const core.String USER_AGENT = 'dart-api-client applications/v1';

class ApplicationsApi {

  final commons.ApiRequester _requester;

  ApplicationsApi(http.Client client, {core.String rootUrl: "http://localhost:8080/", core.String servicePath: "applications/v1/"}) :
      _requester = new commons.ApiRequester(client, rootUrl, servicePath, USER_AGENT);

  /**
   * [request] - The metadata request object.
   *
   * Request parameters:
   *
   * [appId] - Path parameter: 'appId'.
   *
   * Completes with a [Response].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<Response> addAdminUserApplication(AddAdminUserMessage request, core.String appId) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }
    if (appId == null) {
      throw new core.ArgumentError("Parameter appId is required.");
    }

    _url = 'app/' + commons.Escaper.ecapeVariable('$appId') + '/adminUser';

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
   * Request parameters:
   *
   * [platform] - Query parameter: 'platform'.
   *
   * Completes with a [ResponseList].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<ResponseList> allApplications({core.String platform}) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (platform != null) {
      _queryParams["platform"] = [platform];
    }

    _url = 'search';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new ResponseList.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * [appId] - Path parameter: 'appId'.
   *
   * Completes with a [Response].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<Response> applicationDetail(core.String appId) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (appId == null) {
      throw new core.ArgumentError("Parameter appId is required.");
    }

    _url = 'app/' + commons.Escaper.ecapeVariable('$appId');

    var _response = _requester.request(_url,
                                       "GET",
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
   * Completes with a [Response].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<Response> createApplication(CreateApplication request) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }

    _url = 'create';

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
   * [appId] - Path parameter: 'appId'.
   *
   * [adminEmail] - Query parameter: 'adminEmail'.
   *
   * Completes with a [Response].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<Response> deleteAdminUserApplication(core.String appId, {core.String adminEmail}) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (appId == null) {
      throw new core.ArgumentError("Parameter appId is required.");
    }
    if (adminEmail != null) {
      _queryParams["adminEmail"] = [adminEmail];
    }

    _url = 'app/' + commons.Escaper.ecapeVariable('$appId') + '/adminUser';

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
   * [appId] - Path parameter: 'appId'.
   *
   * Completes with a [Response].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<Response> deleteApplication(core.String appId) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (appId == null) {
      throw new core.ArgumentError("Parameter appId is required.");
    }

    _url = 'app/' + commons.Escaper.ecapeVariable('$appId');

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
   * [appId] - Path parameter: 'appId'.
   *
   * [pageIndex] - Query parameter: 'pageIndex'.
   *
   * [limitPerPage] - Query parameter: 'limitPerPage'.
   *
   * [branch] - Query parameter: 'branch'.
   *
   * Completes with a [Response].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<Response> getApplicationVersions(core.String appId, {core.int pageIndex, core.int limitPerPage, core.String branch}) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (appId == null) {
      throw new core.ArgumentError("Parameter appId is required.");
    }
    if (pageIndex != null) {
      _queryParams["pageIndex"] = ["${pageIndex}"];
    }
    if (limitPerPage != null) {
      _queryParams["limitPerPage"] = ["${limitPerPage}"];
    }
    if (branch != null) {
      _queryParams["branch"] = [branch];
    }

    _url = 'app/' + commons.Escaper.ecapeVariable('$appId') + '/versions';

    var _response = _requester.request(_url,
                                       "GET",
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
   * [appId] - Path parameter: 'appId'.
   *
   * Completes with a [Response].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<Response> updateApplication(UpdateApplication request, core.String appId) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }
    if (appId == null) {
      throw new core.ArgumentError("Parameter appId is required.");
    }

    _url = 'app/' + commons.Escaper.ecapeVariable('$appId');

    var _response = _requester.request(_url,
                                       "PUT",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new Response.fromJson(data));
  }

}



class AddAdminUserMessage {
  core.String email;

  AddAdminUserMessage();

  AddAdminUserMessage.fromJson(core.Map _json) {
    if (_json.containsKey("email")) {
      email = _json["email"];
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (email != null) {
      _json["email"] = email;
    }
    return _json;
  }
}

class CreateApplication {
  core.String description;
  core.String name;
  core.String platform;

  CreateApplication();

  CreateApplication.fromJson(core.Map _json) {
    if (_json.containsKey("description")) {
      description = _json["description"];
    }
    if (_json.containsKey("name")) {
      name = _json["name"];
    }
    if (_json.containsKey("platform")) {
      platform = _json["platform"];
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (description != null) {
      _json["description"] = description;
    }
    if (name != null) {
      _json["name"] = name;
    }
    if (platform != null) {
      _json["platform"] = platform;
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

class ResponseList {
  core.List<core.Map<core.String, core.String>> list;
  core.int status;

  ResponseList();

  ResponseList.fromJson(core.Map _json) {
    if (_json.containsKey("list")) {
      list = _json["list"];
    }
    if (_json.containsKey("status")) {
      status = _json["status"];
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (list != null) {
      _json["list"] = list;
    }
    if (status != null) {
      _json["status"] = status;
    }
    return _json;
  }
}

class UpdateApplication {
  core.String description;
  core.String name;
  core.String platform;

  UpdateApplication();

  UpdateApplication.fromJson(core.Map _json) {
    if (_json.containsKey("description")) {
      description = _json["description"];
    }
    if (_json.containsKey("name")) {
      name = _json["name"];
    }
    if (_json.containsKey("platform")) {
      platform = _json["platform"];
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (description != null) {
      _json["description"] = description;
    }
    if (name != null) {
      _json["name"] = name;
    }
    if (platform != null) {
      _json["platform"] = platform;
    }
    return _json;
  }
}
