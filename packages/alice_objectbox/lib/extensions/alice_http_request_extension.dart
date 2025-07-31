import 'package:alice/model/alice_http_request.dart';
import 'package:alice_objectbox/model/cached_alice_http_request.dart';

/// Extension methods for [AliceHttpRequest].
extension AliceHttpRequestExtension on AliceHttpRequest {
  /// Converts [AliceHttpRequest] to [CachedAliceHttpRequest].
  CachedAliceHttpRequest toCached() => CachedAliceHttpRequest(
    size: size,
    time: time,
    headers: headers,
    body: body,
    contentType: contentType,
    cookies: cookies,
    queryParameters: queryParameters,
    formDataFiles: formDataFiles,
    formDataFields: formDataFields,
  );
}
