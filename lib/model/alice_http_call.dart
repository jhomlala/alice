import 'dart:convert';

import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AliceHttpCall {
  final int id;
  late DateTime createdTime;
  String client = "";
  bool loading = true;
  bool secure = false;
  String method = "";
  String endpoint = "";
  String server = "";
  String uri = "";
  int duration = 0;
  //When using retry call
  int? parentCallId;
  VoidCallback? retryCallBack;
  AliceHttpRequest? request;
  AliceHttpResponse? response;
  AliceHttpError? error;
  static const kDefaultFormDataValue = 'replace-with-your-value';

  bool get shouldShowRetryButton => retryCallBack != null;
  bool get hasParentCall => parentCallId != null;
  AliceHttpCall(this.id) {
    loading = true;
    createdTime = DateTime.now();
  }

  void setResponse(AliceHttpResponse response) {
    this.response = response;
    loading = false;
  }

  String getCurlCommand() {
    List<String> postmanCurl = ['curl ${_renderRequest()}'];
    postmanCurl.addAll([_renderHeader(), _renderData()]);
    return postmanCurl.join(' \\\n\t');
  }

  String _singleQuoteCharacter(String content) {
    return '\'$content\'';
  }

  String _renderRequest() {
    return '--location --request $method ${_singleQuoteCharacter(uri)} ';
  }

  String _renderHeader() {
    final headers = request!.headers;
    if (headers.isEmpty) return '';
    List<String> headerList = [];
    final blackListHeader = [Headers.contentLengthHeader];
    headers.forEach((key, dynamic value) {
      if (!blackListHeader.contains(key))
        headerList.add('--header ${_singleQuoteCharacter('$key: $value')}');
    });
    return headerList.join(' \\\n\t');
  }

  String _renderData() {
    final dynamic requestBody = request?.body;
    final headers = request!.headers;
    String dataContent = '';
    if (requestBody.toString().isEmpty) return dataContent;
    if (requestBody is Map && requestBody.isNotEmpty) {
      final formattedRequestBody = AliceParser.formatBody(
          requestBody, AliceParser.getContentType(headers),
          parseJson: (dynamic data) {
        return jsonEncode(data);
      });

      // try to keep to a single line and use a subshell to preserve any line breaks
      dataContent +=
          "--data-raw ${_singleQuoteCharacter(formattedRequestBody.replaceAll("\n", "\\n"))}";
    } else if (requestBody is String) {
      if (requestBody == 'Form data') {
        final List<String> formList = [];

        if (request?.formDataFiles?.isNotEmpty == true) {
          request?.formDataFiles?.forEach((form) {
            formList.add(
                '--form ${_singleQuoteCharacter('${form.key}=${kDefaultFormDataValue}')}');
          });
        } else if (request?.formDataFields?.isNotEmpty == true) {
          request?.formDataFields?.forEach((form) {
            formList.add(
                '--form ${_singleQuoteCharacter('${form.name}=${form.value}')}');
          });
        }
        dataContent += formList.join(' \\\n\t');
      } else {
        dataContent +=
            "--data-raw ${_singleQuoteCharacter(requestBody.replaceAll("\n", "\\n"))}";
      }
    }
    return dataContent;
  }
}
