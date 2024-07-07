import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart' as http_mock_adapter;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'alice_core_mock.dart';

void main() {
  late AliceCore aliceCore;
  late AliceDioAdapter aliceDioAdapter;
  late Dio dio;
  late http_mock_adapter.DioAdapter dioAdapter;
  setUp(() {
    registerFallbackValue(AliceHttpCall(0));
    registerFallbackValue(AliceHttpResponse());
    aliceCore = AliceCoreMock();
    when(() => aliceCore.addCall(any())).thenAnswer((_) => {});
    when(() => aliceCore.addResponse(any(), any())).thenAnswer((_) => {});
    aliceDioAdapter = AliceDioAdapter();
    aliceDioAdapter.injectCore(aliceCore);

    dio = Dio(BaseOptions(followRedirects: false))
      ..interceptors.add(aliceDioAdapter);
    dioAdapter = http_mock_adapter.DioAdapter(dio: dio);
  });

  group("AliceDioAdapter", () {
    test("should handle GET call with json response", () async {
      dioAdapter.onGet(
        'https://test.com/json',
        (server) => server.reply(
          200,
          '{"result": "ok"}',
          headers: {
            "content-type": ["application/json"]
          },
        ),
        headers: {"content-type": "application/json"},
      );

      await dio.get<void>(
        'https://test.com/json',
        options: Options(
          headers: {"content-type": "application/json"},
        ),
      );

      final requestMatcher = buildRequestMatcher(
        checkTime: true,
        headers: {"content-type": "application/json"},
        contentType: "application/json",
        queryParameters: {},
      );

      final responseMatcher = buildResponseMatcher(checkTime: true);

      final callMatcher = buildCallMatcher(
          checkId: true,
          checkTime: true,
          secured: true,
          loading: true,
          client: 'Dio',
          method: 'GET',
          endpoint: '/json',
          server: 'test.com',
          uri: 'https://test.com/json',
          duration: 0,
          request: requestMatcher,
          response: responseMatcher);

      verify(() => aliceCore.addCall(any(that: callMatcher)));

      final nextResponseMatcher = buildResponseMatcher(
        status: 200,
        size: 16,
        checkTime: true,
        body: '{"result": "ok"}',
        headers: {
          'content-type': '[application/json]'
        },
      );

      verify(
          () => aliceCore.addResponse(any(that: nextResponseMatcher), any()));
    });
  });
}

TypeMatcher<AliceHttpCall> buildCallMatcher({
  bool? checkId,
  bool? checkTime,
  bool? secured,
  bool? loading,
  String? client,
  String? method,
  String? endpoint,
  String? server,
  String? uri,
  int? duration,
  TypeMatcher<AliceHttpRequest>? request,
  TypeMatcher<AliceHttpResponse>? response,
}) {
  var matcher = const TypeMatcher<AliceHttpCall>();
  if (checkId == true) {
    matcher = matcher.having((call) => call.id, "id", greaterThan(0));
  }
  if (checkTime == true) {
    matcher = matcher.having((call) => call.createdTime.millisecondsSinceEpoch,
        "createdTime", greaterThan(0));
  }
  if (secured != null) {
    matcher = matcher.having((call) => call.secure, "secure", equals(secured));
  }
  if (loading != null) {
    matcher =
        matcher.having((call) => call.loading, "loading", equals(loading));
  }
  if (client != null) {
    matcher = matcher.having((call) => call.client, "client", equals(client));
  }
  if (method != null) {
    matcher = matcher.having((call) => call.method, "method", equals(method));
  }
  if (endpoint != null) {
    matcher =
        matcher.having((call) => call.endpoint, "endpoint", equals(endpoint));
  }
  if (server != null) {
    matcher = matcher.having((call) => call.server, "server", equals(server));
  }
  if (uri != null) {
    matcher = matcher.having((call) => call.uri, "uri", equals(uri));
  }
  if (duration != null) {
    matcher =
        matcher.having((call) => call.duration, "duration", equals(duration));
  }
  if (request != null) {
    matcher =
        matcher.having((call) => call.request, "request", equals(request));
  }
  if (response != null) {
    matcher =
        matcher.having((call) => call.response, "response", equals(response));
  }
  return matcher;
}

TypeMatcher<AliceHttpRequest> buildRequestMatcher({
  bool? checkTime,
  Map<String, String>? headers,
  String? contentType,
  Map<String, dynamic>? queryParameters,
}) {
  var matcher = const TypeMatcher<AliceHttpRequest>();
  if (checkTime == true) {
    matcher = matcher.having((request) => request.time.millisecondsSinceEpoch,
        "time", greaterThan(0));
  }
  if (headers != null) {
    for (var header in headers.entries) {
      matcher = matcher.having((request) {
        return request.headers;
      }, "header", ContainsHeader(header));
    }
  }
  if (contentType != null) {
    matcher = matcher.having(
        (request) => request.contentType, "contentType", equals(contentType));
  }
  if (queryParameters != null) {
    matcher = matcher.having((request) => request.queryParameters,
        "queryParameters", equals(queryParameters));
  }

  return matcher;
}

TypeMatcher<AliceHttpResponse> buildResponseMatcher({
  int? status,
  int? size,
  bool? checkTime,
  String? body,
  Map<String, String>? headers,
}) {
  var matcher = const TypeMatcher<AliceHttpResponse>();
  if (status != null) {
    matcher =
        matcher.having((response) => response.status, "status", equals(status));
  }
  if (size != null) {
    matcher = matcher.having((response) => response.size, "size", equals(size));
  }
  if (checkTime == true) {
    matcher = matcher.having((response) => response.time.millisecondsSinceEpoch,
        "time", greaterThan(0));
  }
  if (body != null) {
    matcher = matcher.having(
        (response) => response.body.toString(), "body", equals(body));
  }
  if (headers != null) {
    for (var header in headers.entries) {
      matcher = matcher.having((response) {
        return response.headers;
      }, "header", ContainsHeader(header));
    }
  }
  return matcher;
}

class ContainsHeader extends Matcher {
  final MapEntry<String, String>? _expected;

  const ContainsHeader(this._expected);

  @override
  bool matches(Object? item, Map matchState) {
    if (item is Map<String, String>) {
      final mapItem = item[_expected?.key];
      return mapItem == _expected?.value;
    }
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('contains header').addDescriptionOf(_expected);

  @override
  Description describeMismatch(Object? item, Description mismatchDescription,
      Map matchState, bool verbose) {
    mismatchDescription
        .add('does not contain header')
        .addDescriptionOf(_expected);
    return mismatchDescription;
  }
}
