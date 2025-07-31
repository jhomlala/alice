import 'dart:convert';

import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:flutter/material.dart';

/// Body parser helper used to parsing body data.
class AliceParser {
  static const String _jsonContentTypeSmall = 'content-type';
  static const String _jsonContentTypeBig = 'Content-Type';
  static const String _stream = 'Stream';
  static const String _applicationJson = 'application/json';
  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  /// Tries to parse json. If it fails, it will return the json itself.
  static String _parseJson(dynamic json) {
    try {
      return _encoder.convert(json);
    } catch (_) {
      return json.toString();
    }
  }

  /// Tries to parse json. If it fails, it will return the json itself.
  static dynamic _decodeJson(dynamic body) {
    try {
      return json.decode(body as String);
    } catch (_) {
      return body;
    }
  }

  /// Formats body based on [contentType]. If body is null it will return
  /// [_emptyBody]. Otherwise if body type is json - it will try to format it.
  ///
  static String formatBody({
    required BuildContext context,
    required dynamic body,
    String? contentType,
  }) {
    try {
      if (body == null) {
        return context.i18n(AliceTranslationKey.callRequestBodyEmpty);
      }

      String bodyContent = context.i18n(
        AliceTranslationKey.callRequestBodyEmpty,
      );

      if (contentType == null ||
          !contentType.toLowerCase().contains(_applicationJson)) {
        final bodyTemp = body.toString();

        if (bodyTemp.isNotEmpty) {
          bodyContent = bodyTemp;
        }
      } else {
        if (body is String && body.contains('\n')) {
          bodyContent = body;
        } else {
          if (body is String) {
            if (body.isNotEmpty) {
              // body is minified json, so decode it to a map and let the
              // encoder pretty print this map
              bodyContent = _parseJson(_decodeJson(body));
            }
          } else if (body is Stream) {
            bodyContent = _stream;
          } else {
            bodyContent = _parseJson(body);
          }
        }
      }

      return bodyContent;
    } catch (_) {
      return context.i18n(AliceTranslationKey.parserFailed) + body.toString();
    }
  }

  /// Get content type from [headers]. It looks for json and if it can't find
  /// it, it will return unknown content type.
  static String? getContentType({
    required BuildContext context,
    Map<String, String>? headers,
  }) {
    if (headers != null) {
      if (headers.containsKey(_jsonContentTypeSmall)) {
        return headers[_jsonContentTypeSmall];
      }
      if (headers.containsKey(_jsonContentTypeBig)) {
        return headers[_jsonContentTypeBig];
      }
    }
    return context.i18n(AliceTranslationKey.unknown);
  }

  /// Parses headers from [dynamic] to [Map<String,String>], if possible.
  /// Otherwise it will throw error.
  static Map<String, String> parseHeaders({dynamic headers}) {
    if (headers is Map<String, String>) {
      return headers;
    }

    if (headers is Map<String, dynamic>) {
      return headers.map((key, value) => MapEntry(key, value.toString()));
    }

    throw ArgumentError("Invalid headers value.");
  }
}
