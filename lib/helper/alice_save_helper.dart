import 'dart:convert';
import 'package:alice_lightweight/helper/alice_conversion_helper.dart';
import 'package:alice_lightweight/model/alice_http_call.dart';
import 'package:alice_lightweight/ui/utils/alice_parser.dart';

class AliceSaveHelper {
  static JsonEncoder _encoder = new JsonEncoder.withIndent('  ');

  static Future<String> _buildAliceLog() async {
    StringBuffer stringBuffer = StringBuffer();
    stringBuffer.write("Alice - HTTP Inspector\n");
    stringBuffer.write("Generated: " + DateTime.now().toIso8601String() + "\n");
    stringBuffer.write("\n");
    return stringBuffer.toString();
  }

  static String _buildCallLog(AliceHttpCall call) {
    assert(call != null, "call can't be null");
    StringBuffer stringBuffer = StringBuffer();
    stringBuffer.write("===========================================\n");
    stringBuffer.write("Id: ${call.id}\n");
    stringBuffer.write("============================================\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("General data\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Server: ${call.server} \n");
    stringBuffer.write("Method: ${call.method} \n");
    stringBuffer.write("Endpoint: ${call.endpoint} \n");
    stringBuffer.write("Client: ${call.client} \n");
    stringBuffer
        .write("Duration ${AliceConversionHelper.formatTime(call.duration)}\n");
    stringBuffer.write("Secured connection: ${call.secure}\n");
    stringBuffer.write("Completed: ${!call.loading} \n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Request\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Request time: ${call.request.time}\n");
    stringBuffer.write("Request content type: ${call.request.contentType}\n");
    stringBuffer
        .write("Request cookies: ${_encoder.convert(call.request.cookies)}\n");
    stringBuffer
        .write("Request headers: ${_encoder.convert(call.request.headers)}\n");
    stringBuffer.write(
        "Request size: ${AliceConversionHelper.formatBytes(call.request.size)}\n");
    stringBuffer.write(
        "Request body: ${AliceParser.formatBody(call.request.body, AliceParser.getContentType(call.request.headers))}\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Response\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Response time: ${call.response.time}\n");
    stringBuffer.write("Response status: ${call.response.status}\n");
    stringBuffer.write(
        "Response size: ${AliceConversionHelper.formatBytes(call.response.size)}\n");
    stringBuffer.write(
        "Response headers: ${_encoder.convert(call.response.headers)}\n");
    stringBuffer.write(
        "Response body: ${AliceParser.formatBody(call.response.body, AliceParser.getContentType(call.response.headers))}\n");
    if (call.error != null) {
      stringBuffer.write("--------------------------------------------\n");
      stringBuffer.write("Error\n");
      stringBuffer.write("--------------------------------------------\n");
      stringBuffer.write("Error: ${call.error.error}\n");
      if (call.error.stackTrace != null) {
        stringBuffer.write("Error stacktrace: ${call.error.stackTrace}\n");
      }
    }
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("Curl\n");
    stringBuffer.write("--------------------------------------------\n");
    stringBuffer.write("${call.getCurlCommand()}");
    stringBuffer.write("\n");
    stringBuffer.write("==============================================\n");
    stringBuffer.write("\n");

    return stringBuffer.toString();
  }

  static Future<String> buildCallLog(AliceHttpCall call) async {
    assert(call != null, "call can't be null");
    try {
      return await _buildAliceLog() + _buildCallLog(call);
    } catch (exception) {
      return "Failed to generate call log";
    }
  }
}
