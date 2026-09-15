import 'package:alice/model/alice_translation.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../mock/build_context_mock.dart';

void main() {
  late BuildContext context;
  setUp(() {
    registerFallbackValue(AliceTranslationKey.accept);
    context = BuildContextMock();
  });

  group("AliceBodyParser", () {
    test("should parse json body and pretty print it", () {
      expect(
        AliceParser.formatBody(
          context: context,
          body: '{"id":1,"name":"test"}',
          contentType: "application/json",
        ),
        '{\n  "id": 1,\n  "name": "test"\n}',
      );
    });

    test("should tryDecodeJson correctly", () {
      expect(AliceParser.tryDecodeJson(null), isNull);
      expect(AliceParser.tryDecodeJson(''), isNull);
      expect(AliceParser.tryDecodeJson('{"a":1}'), {'a': 1});
      expect(AliceParser.tryDecodeJson({'a': 1}), {'a': 1});
      expect(AliceParser.tryDecodeJson('invalid json'), isNull);
    });

    test("should parse unknown body", () {
      expect(AliceParser.formatBody(context: context, body: 'test'), 'test');
    });

    test("should parse empty body", () {
      expect(
        AliceParser.formatBody(context: context, body: ''),
        AliceTranslationKey.callRequestBodyEmpty.toString(),
      );
    });

    test("should parse application/json content type", () {
      expect(
        AliceParser.getContentType(
          context: context,
          headers: {'Content-Type': "application/json"},
        ),
        "application/json",
      );

      expect(
        AliceParser.getContentType(
          context: context,
          headers: {'content-type': "application/json"},
        ),
        "application/json",
      );
    });

    test("should parse unknown content type", () {
      expect(
        AliceParser.getContentType(context: context, headers: {}),
        AliceTranslationKey.unknown.toString(),
      );
    });

    test("should parse headers", () {
      expect(AliceParser.parseHeaders(headers: {"id": 0}), {"id": "0"});
      expect(AliceParser.parseHeaders(headers: {"id": "0"}), {"id": "0"});
    });

    test("should not parse headers", () {
      expect(
        () => AliceParser.parseHeaders(headers: "test"),
        throwsArgumentError,
      );
    });
  });
}
