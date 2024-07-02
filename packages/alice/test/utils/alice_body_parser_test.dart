import 'package:alice/model/alice_translation.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:flutter/material.dart';
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
        AliceBodyParser.formatBody(
            context: context,
            body: '{"id": 1, "name": "test}',
            contentType: "application/json"),
        '"{\\"id\\": 1, \\"name\\": \\"test}"',
      );
    });

    test("should parse unknown body", () {
      expect(
        AliceBodyParser.formatBody(
          context: context,
          body: 'test',
        ),
        'test',
      );
    });

    test("should parse empty body", () {
      expect(
        AliceBodyParser.formatBody(
          context: context,
          body: '',
        ),
        AliceTranslationKey.callRequestBodyEmpty.toString(),
      );
    });

    test("should parse application/json content type", () {
      expect(
          AliceBodyParser.getContentType(
            context: context,
            headers: {'Content-Type': "application/json"},
          ),
          "application/json");

      expect(
          AliceBodyParser.getContentType(
            context: context,
            headers: {'content-type': "application/json"},
          ),
          "application/json");
    });

    test("should parse unknown content type", () {
      expect(
          AliceBodyParser.getContentType(
            context: context,
            headers: {},
          ),
          AliceTranslationKey.unknown.toString());
    });
  });
}
