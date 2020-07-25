import 'dart:convert';

import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:dio/dio.dart';

class AliceDioInterceptor extends InterceptorsWrapper {
  /// AliceCore instance
  final AliceCore aliceCore;

  /// Creates dio interceptor
  AliceDioInterceptor(this.aliceCore)
      : assert(aliceCore != null, "aliceCore can't be null");

  /// Handles dio request and creates alice http call based on it
  @override
  Future onRequest(RequestOptions options) {
    assert(options != null, "options can't be null");
    AliceHttpCall call = new AliceHttpCall(options.hashCode);

    Uri uri = options.uri;
    call.method = options.method;
    var path = options.uri.path;
    if (path == null || path.length == 0) {
      path = "/";
    }
    call.endpoint = path;
    call.server = uri.host;
    call.client = "Dio";
    call.uri = options.uri.toString();

    if (uri.scheme == "https") {
      call.secure = true;
    }

    AliceHttpRequest request = AliceHttpRequest();

    var data = options.data;
    if (data == null) {
      request.size = 0;
      request.body = "";
    } else {
      if (data is FormData) {
        request.body += "Form data";

        if (data.fields?.isNotEmpty == true) {
          List<AliceFormDataField> fields = List();
          data.fields.forEach((entry) {
            fields.add(AliceFormDataField(entry.key, entry.value));
          });
          request.formDataFields = fields;
        }
        if (data.files?.isNotEmpty == true) {
          List<AliceFormDataFile> files = List();
          data.files.forEach((entry) {
            files.add(AliceFormDataFile(entry.value.filename,
                entry.value.contentType.toString(), entry.value.length));
          });

          request.formDataFiles = files;
        }
      } else {
        request.size = utf8.encode(data.toString()).length;
        request.body = data;
      }
    }

    request.time = DateTime.now();
    request.headers = options.headers;
    request.contentType = options.contentType.toString();
    request.queryParameters = options.queryParameters;

    call.request = request;
    call.response = AliceHttpResponse();

    aliceCore.addCall(call);
    return super.onRequest(options);
  }

  /// Handles dio response and adds data to alice http call
  @override
  Future onResponse(Response response) {
    assert(response != null, "response can't be null");
    var httpResponse = AliceHttpResponse();
    httpResponse.status = response.statusCode;

    if (response.data == null) {
      httpResponse.body = "";
      httpResponse.size = 0;
    } else {
      httpResponse.body = response.data;
      httpResponse.size = utf8.encode(response.data.toString()).length;
    }

    httpResponse.time = DateTime.now();
    Map<String, String> headers = Map();
    if (response.headers != null) {
      response.headers.forEach((header, values) {
        headers[header] = values.toString();
      });
    }
    httpResponse.headers = headers;

    aliceCore.addResponse(httpResponse, response.request.hashCode);
    return super.onResponse(response);
  }

  /// Handles error and adds data to alice http call
  @override
  Future onError(DioError error) {
    assert(error != null, "error can't be null");
    var httpError = AliceHttpError();
    httpError.error = error.toString();
    if (error is Error) {
      var basicError = error as Error;
      httpError.stackTrace = basicError.stackTrace;
    }

    aliceCore.addError(httpError, error.request.hashCode);
    var httpResponse = AliceHttpResponse();
    httpResponse.time = DateTime.now();
    if (error.response == null) {
      httpResponse.status = -1;
      aliceCore.addResponse(httpResponse, error.request.hashCode);
    } else {
      httpResponse.status = error.response.statusCode;

      if (error.response.data == null) {
        httpResponse.body = "";
        httpResponse.size = 0;
      } else {
        httpResponse.body = error.response.data;
        httpResponse.size = utf8.encode(error.response.data.toString()).length;
      }
      Map<String, String> headers = Map();
      if (error.response.headers != null) {
        error.response.headers.forEach((header, values) {
          headers[header] = values.toString();
        });
      }
      httpResponse.headers = headers;
      aliceCore.addResponse(httpResponse, error.response.request.hashCode);
    }

    return super.onError(error);
  }
}
