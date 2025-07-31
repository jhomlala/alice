import 'package:alice/model/alice_http_response.dart';
import 'package:alice_objectbox/model/cached_alice_http_response.dart';

/// Extension methods for [AliceHttpResponse].
extension AliceHttpResponseExtension on AliceHttpResponse {
  /// Converts [AliceHttpResponse] to [CachedAliceHttpResponse].
  CachedAliceHttpResponse toCached() => CachedAliceHttpResponse(
    status: status,
    size: size,
    time: time,
    body: body,
    headers: headers,
  );
}
