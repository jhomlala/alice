import 'dart:io' show HttpHeaders;

import 'package:alice/model/alice_http_call.dart';

class Curl {
  /// Builds Curl command based on [call] instance.
  static String getCurlCommand(AliceHttpCall call) {
    bool compressed = false;
    final StringBuffer curlCmd = StringBuffer('curl');

    curlCmd.write(' -X ${call.method}');

    for (final MapEntry<String, String> header
        in call.request?.headers.entries ?? []) {
      if (header.key.toLowerCase() == HttpHeaders.acceptEncodingHeader &&
          header.value.toString().toLowerCase() == 'gzip') {
        compressed = true;
      }

      curlCmd.write(' -H "${header.key}: ${header.value}"');
    }

    final String? requestBody = call.request?.body.toString();
    if (requestBody?.isNotEmpty ?? false) {
      // try to keep to a single line and use a subshell to preserve any line
      // breaks
      curlCmd.write(" --data \$'${requestBody?.replaceAll("\n", r"\n")}'");
    }

    final Map<String, dynamic>? queryParamMap = call.request?.queryParameters;
    int paramCount = queryParamMap?.keys.length ?? 0;
    final StringBuffer queryParams = StringBuffer();

    if (paramCount > 0) {
      queryParams.write('?');
      for (final MapEntry<String, dynamic> queryParam
          in queryParamMap?.entries ?? []) {
        queryParams.write('${queryParam.key}=${queryParam.value}');
        paramCount--;
        if (paramCount > 0) {
          queryParams.write('&');
        }
      }
    }

    // If server already has http(s) don't add it again
    if (call.server.contains('http://') || call.server.contains('https://')) {
      // ignore: join_return_with_assignment
      curlCmd.write(
        "${compressed ? " --compressed " : " "}"
        "${"'${call.server}${call.endpoint}$queryParams'"}",
      );
    } else {
      // ignore: join_return_with_assignment
      curlCmd.write(
        "${compressed ? " --compressed " : " "}"
        "${"'${call.secure ? 'https://' : 'http://'}${call.server}${call.endpoint}$queryParams'"}",
      );
    }

    return curlCmd.toString();
  }
}
