import 'package:alice/model/alice_http_call.dart';
import 'package:alice_objectbox/model/cached_alice_http_call.dart';

/// Extension methods for [AliceHttpCall].
extension AliceHttpCallExtension on AliceHttpCall {
  /// Converts [AliceHttpCall] to [CachedAliceHttpCall].
  CachedAliceHttpCall toCached() =>
      CachedAliceHttpCall(
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
