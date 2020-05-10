import 'dart:convert';

class AliceParser{

  static final JsonEncoder encoder = new JsonEncoder.withIndent('  ');

  static String _parseJson(dynamic json) {
    try {
      return encoder.convert(json);
    } catch (exception) {
      return json;
    }
  }

  static String _decodeJson(dynamic body) {
    try {
      return json.decode(body);
    } catch (exception) {
      return body;
    }
  }

  static String formatBody(dynamic body, String contentType) {
    try {
      var bodyContent = "Body is empty";
      if (body != null) {
        if (contentType == null ||
            !contentType.toLowerCase().contains("application/json")) {
          return body.toString();
        } else {
          if (body is String && body.contains("\n")) {
            bodyContent = body;
          } else {
            if (body is String) {
              if (body.length != 0) {
                //body is minified json, so decode it to a map and let the encoder pretty print this map
                bodyContent = _parseJson(_decodeJson(body));
              }
            } else if (body is Stream) {
              bodyContent = "Stream";
            } else {
              bodyContent = _parseJson(body);
            }
          }
        }
      }
      return bodyContent;
    } catch (exception) {
      return "Failed to parse body: " + body.toString();
    }
  }

  static String getContentType(Map<String, dynamic> headers) {
    if (headers != null) {
      if (headers.containsKey("content-type")) {
        return headers["content-type"];
      }
      if (headers.containsKey("Content-Type")) {
        return headers["Content-Type"];
      }
    }
    return "???";
  }


}

