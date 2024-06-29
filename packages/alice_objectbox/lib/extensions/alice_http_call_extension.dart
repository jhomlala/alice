import 'package:alice/model/alice_http_call.dart';
import 'package:alice_objectbox/model/cached_alice_http_call.dart';

extension AliceHttpCallExtension on AliceHttpCall {
  CachedAliceHttpCall toCached() => CachedAliceHttpCall(
        id,
        client: client,
        loading: loading,
        secure: secure,
        method: method,
        endpoint: endpoint,
        server: server,
        uri: uri,
        duration: duration,
      )
        ..error = error
        ..request = request
        ..response = response;
}
