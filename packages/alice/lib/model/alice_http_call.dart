import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';

class AliceHttpCall {
  AliceHttpCall(this.id) {
    loading = true;
    createdTime = DateTime.now();
  }

  final int id;
  late DateTime createdTime;
  String client = '';
  bool loading = true;
  bool secure = false;
  String method = '';
  String endpoint = '';
  String server = '';
  String uri = '';
  int duration = 0;

  AliceHttpRequest? request;
  AliceHttpResponse? response;
  AliceHttpError? error;

  void setResponse(AliceHttpResponse response) {
    this.response = response;
    loading = false;
  }

  String getCurlCommand() {
    bool compressed = false;
    final StringBuffer curlCmd = StringBuffer('curl');

    curlCmd.write(' -X $method');

    for (final MapEntry<String, dynamic> header
        in request?.headers.entries ?? []) {
      if ('Accept-Encoding' == header.key && header.value == 'gzip') {
        compressed = true;
      }

      curlCmd.write(' -H "${header.key}: ${header.value}"');
    }

    final String? requestBody = request?.body.toString();
    if (requestBody?.isNotEmpty ?? false) {
      // try to keep to a single line and use a subshell to preserve any line
      // breaks
      curlCmd.write(" --data \$'${requestBody?.replaceAll("\n", r"\n")}'");
    }

    final Map<String, dynamic>? queryParamMap = request?.queryParameters;
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
    if (server.contains('http://') || server.contains('https://')) {
      // ignore: join_return_with_assignment
      curlCmd.write(
        "${compressed ? " --compressed " : " "}"
        "${"'$server$endpoint$queryParams'"}",
      );
    } else {
      // ignore: join_return_with_assignment
      curlCmd.write(
        "${compressed ? " --compressed " : " "}"
        "${"'${secure ? 'https://' : 'http://'}$server$endpoint$queryParams'"}",
      );
    }

    return curlCmd.toString();
  }
}
