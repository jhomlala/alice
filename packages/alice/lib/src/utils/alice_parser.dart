import 'dart:convert';

import 'package:alice/src/model/translation.dart';
import 'package:alice/src/ui/common/context_ext.dart';
import 'package:material_ui/material_ui.dart';

/// Body parser utility used to parsing body data.
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
      if (body is String) {
        return json.decode(body);
      }
      return body;
    } catch (_) {
      return body;
    }
  }

  /// Tries to decode json. If it fails, it will return null.
  static dynamic tryDecodeJson(dynamic body) {
    if (body == null || body is Stream) {
      return null;
    }

    try {
      if (body is String) {
        if (body.isEmpty) return null;
        return json.decode(body);
      }
      if (body is Map || body is List) {
        return body;
      }
      return null;
    } catch (_) {
      return null;
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
        return context.i18n(TranslationKey.callRequestBodyEmpty);
      }

      String bodyContent = context.i18n(TranslationKey.callRequestBodyEmpty);

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
      return context.i18n(TranslationKey.parserFailed) + body.toString();
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
    return context.i18n(TranslationKey.unknown);
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
