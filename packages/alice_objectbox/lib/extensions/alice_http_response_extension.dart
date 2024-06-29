import 'package:alice/model/alice_http_response.dart';
import 'package:alice_objectbox/model/cached_alice_http_response.dart';

extension AliceHttpResponseExtension on AliceHttpResponse {
  CachedAliceHttpResponse toCachedAliceHttpResponse() =>
      CachedAliceHttpResponse(
        status: status,
        size: size,
        time: time,
        body: body,
        headers: headers,
      );
}
