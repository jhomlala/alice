import 'package:alice/model/alice_http_request.dart';
import 'package:alice_objectbox/model/cached_alice_http_request.dart';

extension AliceHttpRequestExtension on AliceHttpRequest {
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
