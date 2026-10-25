import 'dart:convert';

import 'package:alice/src/model/alice_configuration.dart';
import 'package:alice/src/model/alice_cookie.dart';
import 'package:alice/src/model/alice_form_data_field.dart';
import 'package:alice/src/model/alice_http_call.dart';
import 'package:alice/src/model/alice_http_request.dart';
import 'package:alice/src/model/alice_http_response.dart';

/// Service responsible for redacting sensitive information from HTTP calls at capture time.
class AliceRedactionService {
  final Set<String> _headersLower;
  final Set<String> _bodyKeysLower;
  final String _replacement;

  AliceRedactionService({required AliceConfiguration configuration})
    : _headersLower = configuration.redactedHeaders
          .map((e) => e.toLowerCase())
          .toSet(),
      _bodyKeysLower = configuration.redactedBodyKeys
          .map((e) => e.toLowerCase())
          .toSet(),
      _replacement = configuration.redactionReplacement;

  /// Returns true if any redaction rules are configured.
  bool get isEnabled => _headersLower.isNotEmpty || _bodyKeysLower.isNotEmpty;

  /// Redacts sensitive information from [call].
  void redactCall(AliceHttpCall call) {
    if (!isEnabled) {
      return;
    }
    if (call.request != null) {
      redactRequest(call.request!);
    }
    if (call.response != null) {
      redactResponse(call.response!);
    }
  }

  /// Redacts sensitive information from [request].
  void redactRequest(AliceHttpRequest request) {
    if (!isEnabled) {
      return;
    }

    // Redact headers
    if (_headersLower.isNotEmpty && request.headers.isNotEmpty) {
      final sanitizedHeaders = <String, String>{};
      for (final entry in request.headers.entries) {
        if (_headersLower.contains(entry.key.toLowerCase())) {
          sanitizedHeaders[entry.key] = _replacement;
        } else {
          sanitizedHeaders[entry.key] = entry.value;
        }
      }
      request.headers = sanitizedHeaders;
    }

    // Redact cookies
    if (request.cookies.isNotEmpty) {
      final shouldRedactAllCookies = _headersLower.contains('cookie');
      final sanitizedCookies = <AliceCookie>[];
      for (final cookie in request.cookies) {
        if (shouldRedactAllCookies ||
            _headersLower.contains(cookie.name.toLowerCase()) ||
            _bodyKeysLower.contains(cookie.name.toLowerCase())) {
          sanitizedCookies.add(AliceCookie(cookie.name, _replacement));
        } else {
          sanitizedCookies.add(cookie);
        }
      }
      request.cookies = sanitizedCookies;
    }

    // Redact query parameters
    if (_bodyKeysLower.isNotEmpty && request.queryParameters.isNotEmpty) {
      final sanitizedQueryParams = <String, dynamic>{};
      for (final entry in request.queryParameters.entries) {
        if (_bodyKeysLower.contains(entry.key.toLowerCase())) {
          sanitizedQueryParams[entry.key] = _replacement;
        } else {
          sanitizedQueryParams[entry.key] = entry.value;
        }
      }
      request.queryParameters = sanitizedQueryParams;
    }

    // Redact form data fields
    if (_bodyKeysLower.isNotEmpty && request.formDataFields != null) {
      final sanitizedFields = <AliceFormDataField>[];
      for (final field in request.formDataFields!) {
        if (_bodyKeysLower.contains(field.name.toLowerCase())) {
          sanitizedFields.add(AliceFormDataField(field.name, _replacement));
        } else {
          sanitizedFields.add(field);
        }
      }
      request.formDataFields = sanitizedFields;
    }

    // Redact body
    if (_bodyKeysLower.isNotEmpty && request.body != null) {
      request.body = _redactBody(request.body);
    }
  }

  /// Redacts sensitive information from [response].
  void redactResponse(AliceHttpResponse response) {
    if (!isEnabled) {
      return;
    }

    // Redact headers
    if (_headersLower.isNotEmpty && response.headers != null) {
      final sanitizedHeaders = <String, String>{};
      for (final entry in response.headers!.entries) {
        if (_headersLower.contains(entry.key.toLowerCase())) {
          sanitizedHeaders[entry.key] = _replacement;
        } else {
          sanitizedHeaders[entry.key] = entry.value;
        }
      }
      response.headers = sanitizedHeaders;
    }

    // Redact body
    if (_bodyKeysLower.isNotEmpty && response.body != null) {
      response.body = _redactBody(response.body);
    }
  }

  /// Recursively walks and redacts maps/lists/json strings or urlencoded query strings.
  dynamic _redactBody(dynamic body) {
    if (_bodyKeysLower.isEmpty || body == null) {
      return body;
    }

    if (body is Map) {
      final sanitized = <dynamic, dynamic>{};
      for (final entry in body.entries) {
        final keyStr = entry.key.toString();
        if (_bodyKeysLower.contains(keyStr.toLowerCase())) {
          sanitized[entry.key] = _replacement;
        } else {
          sanitized[entry.key] = _redactBody(entry.value);
        }
      }
      return sanitized;
    }

    if (body is List) {
      return body.map(_redactBody).toList();
    }

    if (body is String) {
      final trimmed = body.trim();
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        try {
          final decoded = jsonDecode(trimmed);
          final redacted = _redactBody(decoded);
          return jsonEncode(redacted);
        } catch (_) {
          return body;
        }
      }

      // Handle x-www-form-urlencoded strings (e.g. "user=alice&password=secret&token=123")
      if (trimmed.contains('=') &&
          !trimmed.contains('\n') &&
          !trimmed.contains('{')) {
        final pairs = trimmed.split('&');
        var wasModified = false;
        final sanitizedPairs = pairs.map((pair) {
          final eqIndex = pair.indexOf('=');
          if (eqIndex != -1) {
            final key = pair.substring(0, eqIndex);
            final keyDecoded = Uri.decodeQueryComponent(key);
            if (_bodyKeysLower.contains(keyDecoded.toLowerCase())) {
              wasModified = true;
              return '$key=${Uri.encodeQueryComponent(_replacement)}';
            }
          }
          return pair;
        }).toList();

        if (wasModified) {
          return sanitizedPairs.join('&');
        }
      }
    }

    return body;
  }
}
