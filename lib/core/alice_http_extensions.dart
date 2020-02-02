import 'package:alice/alice.dart';
import 'package:http/http.dart';

extension AliceHttpExtensions on Future<Response> {
  Future<Response> interceptWithAlice(Alice alice, {dynamic body}) async {
    Response response = await this;
    alice.onHttpResponse(response, body: body);
    return response;
  }
}
