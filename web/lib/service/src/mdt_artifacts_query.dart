import 'package:angular/angular.dart';
import 'dart:convert';
import "dart:html";
import 'dart:async';
import '../../model/errors.dart';
import '../../model/mdt_model.dart';
import 'mdt_conf_query.dart';

abstract class MDTQueryServiceArtifacts {
  Future<HttpResponse> sendRequest(String method, String url,
      {String query, String body, String contentType}) async {
    throw 'Not Implemented';
  }
  Map parseResponse(HttpResponse response,{checkAuthorization:true}) {
    throw 'Not Implemented';
  }
  void sendRedirect(String url){
    throw 'Not Implemented';
  }

  Future<List<MDTArtifact>> listLatestArtifacts(String appId) async {
    var url = '${mdtServerApiRootUrl}${appPath}/app/${appId}/versions/last';

    print("Loads latest version url $url");

    var response = await sendRequest('GET', url);
    var responseJson = parseResponse(response);

    if (responseJson["error"] != null) {
      throw new ApplicationError(responseJson["error"]["message"]);
    }

    var artifactsList = new List<MDTArtifact>();

    var artList = responseJson["list"];
    if (artList != null) {
      for (Map app in artList) {
        artifactsList.add(new MDTArtifact(app));
      }
    }

    return artifactsList;
  }

  Future<List<MDTArtifact>> listArtifacts(String appId, {int pageIndex, int limitPerPage,String branch}) async{
    var url = '${mdtServerApiRootUrl}${appPath}/app/${appId}/versions';
    var parameters ={};
    if (pageIndex != null ){
      parameters["pageIndex"] = pageIndex;
    }
    if (limitPerPage != null ){
      parameters["limitPerPage"] = limitPerPage;
    }
    if (branch != null ){
      parameters["branch"] = branch;
    }
    var separator = "?";
    parameters.forEach((k,v){url+="$separator$k=$v";separator="&";});
    print("Loads version url $url");

    var response = await sendRequest('GET', url);
    var responseJson = parseResponse(response);

    if (responseJson["error"] != null) {
      throw new ApplicationError(responseJson["error"]["message"]);
    }

    var artifactsList = new List<MDTArtifact>();

    var artList = responseJson["list"];
    if (artList != null) {
      for (Map app in artList) {
        artifactsList.add(new MDTArtifact(app));
      }
    }

    return artifactsList;
  }

  Future<MDTArtifact> addArtifact(String apiKey, File file, String name,
      {bool latest,
      String branch,
      String version,
      String jsonTags,
      String sortIdentifier}) async {
    if ((apiKey == null) || (file == null) || (name == null)) {
      throw new ArtifactsError("Bad parameters");
    }
    var url = '${mdtServerApiRootUrl}${inPath}/artifacts/${apiKey}';
    if (latest) {
      url = '$url/last/$name';
    } else {
      if ((branch == null) || (version == null)) {
        throw new ArtifactsError("Bad parameters, missing branch or version");
      }
      url = '$url/$branch/$version/$name';
    }

    var formData = new FormData();
    formData.appendBlob("artifactFile", file);
    if (sortIdentifier != null) {
      formData.append("sortIdentifier", sortIdentifier);
    }

    if (jsonTags != null) {
      formData.append("jsonTags", jsonTags);
    }
    var responseJson = {};
    try {

      var response = await HttpRequest.request(
          url, method: "POST", sendData: formData);

      responseJson = JSON.decode(response.response);
      //parseResponse(response.response,checkAuthorization:false);
    }catch(e){
      var responseText = e.target.responseText;
      responseJson = JSON.decode(responseText);
    }
    if (responseJson["error"] != null) {
      throw new ArtifactsError(responseJson["error"]["message"]);
    }
    var artifact = responseJson["data"];
    if (artifact != null) {
      return new MDTArtifact(artifact);
    }


    throw new ArtifactsError("Unable to parse response ${responseJson}");
  }

  Future<Map> artifactDownloadInfo(String artifactId) async {
    var url = '${mdtServerApiRootUrl}${artifactsPath}/artifacts/${artifactId}/download';
    var response = await sendRequest('GET', url);
    var responseJson = parseResponse(response);

    if (responseJson["error"] != null) {
      throw new ArtifactsError(responseJson["error"]["message"]);
    }
    return responseJson["data"];
  }

  Future<bool> deleteArtifact(String artifactId) async {
    var url = '${mdtServerApiRootUrl}${artifactsPath}/artifacts/${artifactId}';
    var response = await sendRequest('DELETE', url);
    if (response.status == 200){
      return new Future.value(true);
    }
    return new Future.value(false);
  }

  Future<bool> downloadArtifact(String artifactId) async {
    var downloadInfos = await artifactDownloadInfo(artifactId);
    if (downloadInfos != null){
      var url = downloadInfos["directLinkUrl"];
      sendRedirect(url);
      new Future.value(true);
    }
    return new Future.value(false);
  }

  Future<bool> InstallArtifact(String artifactId) async {
    var downloadInfos = await artifactDownloadInfo(artifactId);
    if (downloadInfos != null){
      var url = downloadInfos["installUrl"];
      print('redirect :$url, map ${downloadInfos.toString()}');
      sendRedirect(url);
      new Future.value(true);
    }
    return new Future.value(false);
  }
}