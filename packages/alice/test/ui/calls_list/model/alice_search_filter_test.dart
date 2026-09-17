import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/calls_list/model/search_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../mock/mocked_data.dart';

void main() {
  group("SearchFilter", () {
    late AliceHttpCall call;

    setUp(() {
      call =
          MockedData.getFilledHttpCall()
            ..method = "GET"
            ..endpoint = "/api/users"
            ..server = "https://google.com"
            ..client = "Dio"
            ..duration = 150;
      call.response?.status = 200;
    });

    test("should parse and apply method filter", () {
      final filter = SearchFilter.parse("method:GET");
      expect(filter.method, "get");
      expect(filter.apply(call), true);

      final filter2 = SearchFilter.parse("method:POST");
      expect(filter2.apply(call), false);
    });

    test("should parse and apply status filter", () {
      final filter = SearchFilter.parse("status:200");
      expect(filter.status, "200");
      expect(filter.apply(call), true);

      final filter2 = SearchFilter.parse("status:404");
      expect(filter2.apply(call), false);
    });

    test("should parse and apply host filter", () {
      final filter = SearchFilter.parse("host:google");
      expect(filter.host, "google");
      expect(filter.apply(call), true);

      final filter2 = SearchFilter.parse("host:apple");
      expect(filter2.apply(call), false);
    });

    test("should parse and apply server filter (alias for host)", () {
      final filter = SearchFilter.parse("server:google");
      expect(filter.host, "google");
      expect(filter.apply(call), true);
    });

    test("should parse and apply client filter", () {
      final filter = SearchFilter.parse("client:dio");
      expect(filter.client, "dio");
      expect(filter.apply(call), true);

      final filter2 = SearchFilter.parse("client:http");
      expect(filter2.apply(call), false);
    });

    test("should parse and apply duration filter", () {
      final filter = SearchFilter.parse("duration:100");
      expect(filter.duration, "100");
      expect(filter.apply(call), true);

      final filter2 = SearchFilter.parse("duration:200");
      expect(filter2.apply(call), false);

      final filter3 = SearchFilter.parse("duration:>100");
      expect(filter3.apply(call), true);

      final filter4 = SearchFilter.parse("duration:<100");
      expect(filter4.apply(call), false);

      final filter5 = SearchFilter.parse("duration:=150");
      expect(filter5.apply(call), true);
    });

    test("should handle case-insensitive keys", () {
      final filter = SearchFilter.parse("Method:GET STATUS:200");
      expect(filter.method, "get");
      expect(filter.status, "200");
      expect(filter.apply(call), true);
    });

    test("should parse and apply plain text search", () {
      final filter = SearchFilter.parse("users");
      expect(filter.text, "users");
      expect(filter.apply(call), true);

      final filter2 = SearchFilter.parse("customers");
      expect(filter2.apply(call), false);
    });

    test("should combine filters and text search", () {
      final filter = SearchFilter.parse("status:200 method:GET users");
      expect(filter.status, "200");
      expect(filter.method, "get");
      expect(filter.text, "users");
      expect(filter.apply(call), true);

      final filter2 = SearchFilter.parse("status:200 method:POST users");
      expect(filter2.apply(call), false);
    });

    test("should handle empty query", () {
      final filter = SearchFilter.parse("");
      expect(filter.apply(call), true);
    });

    group("Edge Cases and Complex Scenarios", () {
      test(
        "should use the last filter if multiple of the same type are provided",
        () {
          final filter = SearchFilter.parse("method:POST method:GET");
          expect(filter.method, "get");
          expect(filter.apply(call), true);

          final filter2 = SearchFilter.parse("status:404 status:200");
          expect(filter2.status, "200");
          expect(filter2.apply(call), true);
        },
      );

      test("should handle invalid duration gracefully", () {
        final filter = SearchFilter.parse("duration:abc");
        expect(
          filter.apply(call),
          true,
        ); // Invalid duration should not filter out

        final filter2 = SearchFilter.parse("duration:>xyz");
        expect(filter2.apply(call), true);
      });

      test("should handle multiple text terms", () {
        final filter = SearchFilter.parse("api users");
        expect(filter.text, "api users");
        expect(filter.apply(call), true);

        final filter2 = SearchFilter.parse("method:GET api users");
        expect(filter2.method, "get");
        expect(filter2.text, "api users");
        expect(filter2.apply(call), true);
      });

      test("should handle values with special characters in text search", () {
        final filter = SearchFilter.parse("/api/users?id=1");
        expect(filter.text, "/api/users?id=1");
        // endpoint is /api/users, so this won't match unless the endpoint includes query params
        // MockedData.getFilledHttpCall sets endpoint to /test
        call.endpoint = "/api/users?id=1";
        expect(filter.apply(call), true);
      });

      test("should handle keys without values or malformed filters", () {
        final filter = SearchFilter.parse("method: status: host:");
        // The regex (method|status|host|server|client|duration):([^\s]+)
        // will not match "method: " because ([^\s]+) requires at least one non-space char.
        expect(filter.method, isNull);
        expect(filter.text, "method: status: host:");
        // It won't match /api/users because it contains "method:" etc.
        expect(filter.apply(call), false);
      });
    });
  });
}
