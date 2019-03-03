import 'dart:convert';

import 'package:alice/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:http/http.dart' as http;

class AliceHttpAdapter{
  final AliceCore core;

  AliceHttpAdapter(this.core);

  onResponse(http.Response response, {dynamic body}){
    if (response == null){
      print("Cant process null http.Response");
      return;
    }
    if (response.request == null){
      print("Cant process null http.Request");
      return;
    }
    var request = response.request;

    AliceHttpCall call = AliceHttpCall(response.request.hashCode);
    call.loading = true;
    call.client = "HttpClient (io package)";
    call.method = request.method;
    call.endpoint = request.url.path;
    call.server = request.url.host;
    if (request.url.scheme == "https") {
      call.secure = true;
    }

    AliceHttpRequest httpRequest = AliceHttpRequest();
    if (body == null) {
      httpRequest.size = 0;
      httpRequest.body = "";
    } else {
      httpRequest.size = utf8.encode(body.toString()).length;
      httpRequest.body = body;
    }
    httpRequest.time = DateTime.now();
    Map<String, dynamic> headers = Map();
    httpRequest.headers.forEach((header, value) {
      headers[header] = value;
    });

    httpRequest.headers = headers;
    String contentType = "unknown";
    if (headers.containsKey("Content-Type")) {
      contentType = headers["Content-Type"];
    }

    httpRequest.contentType = contentType;

    AliceHttpResponse httpResponse = AliceHttpResponse();
    httpResponse.status = response.statusCode;
    httpResponse.body = response.body;
    httpResponse.size = utf8.encode(response.body.toString()).length;
    httpResponse.time = DateTime.now();
    Map<String, String> responseHeaders = Map();
    response.headers.forEach((header, values) {
      responseHeaders[header] = values.toString();
    });
    httpResponse.headers = responseHeaders;



    call.request = httpRequest;
    call.response = httpResponse;

    call.loading = false;
    call.duration = 0;
    core.addCall(call);
  }

}