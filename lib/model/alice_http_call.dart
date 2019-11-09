import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';

class AliceHttpCall {
  final int id;
  String client = "";
  bool loading = true;
  bool secure = false;
  String method = "";
  String endpoint = "";
  String server = "";
  int duration = 0;

  AliceHttpRequest request;
  AliceHttpResponse response;
  AliceHttpError error;

  AliceHttpCall(this.id) {
    loading = true;
  }

  setResponse(AliceHttpResponse response) {
    this.response = response;
    loading = false;
  }

  String getCurlCommand() {
    var compressed = false;
    var curlCmd = "curl";
    curlCmd += " -X " + method;
    var headers = request.headers;
    headers.forEach((key, value) {
      if ("Accept-Encoding" == key && "gzip" == value) {
        compressed = true;
      }
      curlCmd += " -H \'$key: $value\'";
    });

    String requestBody = request.body.toString();
    if (requestBody != null && requestBody != '') {
      // try to keep to a single line and use a subshell to preserve any line breaks
      curlCmd += " --data \$'" + requestBody.replaceAll("\n", "\\n") + "'";
    }
    curlCmd += ((compressed) ? " --compressed " : " ") +
        "\'${secure ? 'https://' : 'http://'}$server$endpoint\'";
    return curlCmd;
  }

  String getCallLog() {
    return '${request.time.toString()}\n' +
        '$endpoint\n$method' +
        '\n${request.body}\n${response.status}' +
        '\n${response.body}\n';
  }
}
