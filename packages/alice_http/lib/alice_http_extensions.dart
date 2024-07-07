import 'package:alice_http/alice_http_adapter.dart';
import 'package:http/http.dart';

extension AliceHttpExtensions on Future<Response> {
  /// Intercept http request with alice. This extension method provides
  /// additional helpful method to intercept https' response.
  Future<Response> interceptWithAlice(
    AliceHttpAdapter adapter, {
    dynamic body,
  }) async {
    final response = await this;
    adapter.onResponse(response, body: body);
    return response;
  }
}
