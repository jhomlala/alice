import 'package:alice_http/alice_http_adapter.dart';
import 'package:http/http.dart';

extension AliceHttpExtensions on Future<Response> {
  /// Intercept http request with alice. This extension method provides
  /// additional helpful method to intercept https' response.
  Future<Response> interceptWithAlice(
    AliceHttpAdapter adapter, {
    dynamic body,
  }) async {
    final startTime = DateTime.now();
    final response = await this;
    final endTime = DateTime.now();
    adapter.onResponse(
      response,
      body: body,
      duration: endTime.difference(startTime),
    );
    return response;
  }
}
