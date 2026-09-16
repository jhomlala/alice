import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/calls_list/model/alice_search_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../mock/mocked_data.dart';

void main() {
  group("AliceSearchFilter", () {
    late AliceHttpCall call;

    setUp(() {
      call = MockedData.getFilledHttpCall()
        ..method = "GET"
        ..endpoint = "/api/users"
        ..server = "https://google.com"
        ..client = "Dio"
        ..duration = 150;
      call.response?.status = 200;
    });

    test("should parse and apply method filter", () {
      final filter = AliceSearchFilter.parse("method:GET");
      expect(filter.method, "get");
      expect(filter.apply(call), true);

      final filter2 = AliceSearchFilter.parse("method:POST");
      expect(filter2.apply(call), false);
    });

    test("should parse and apply status filter", () {
      final filter = AliceSearchFilter.parse("status:200");
      expect(filter.status, "200");
      expect(filter.apply(call), true);

      final filter2 = AliceSearchFilter.parse("status:404");
      expect(filter2.apply(call), false);
    });

    test("should parse and apply host filter", () {
      final filter = AliceSearchFilter.parse("host:google");
      expect(filter.host, "google");
      expect(filter.apply(call), true);

      final filter2 = AliceSearchFilter.parse("host:apple");
      expect(filter2.apply(call), false);
    });

    test("should parse and apply server filter (alias for host)", () {
      final filter = AliceSearchFilter.parse("server:google");
      expect(filter.host, "google");
      expect(filter.apply(call), true);
    });

    test("should parse and apply client filter", () {
      final filter = AliceSearchFilter.parse("client:dio");
      expect(filter.client, "dio");
      expect(filter.apply(call), true);

      final filter2 = AliceSearchFilter.parse("client:http");
      expect(filter2.apply(call), false);
    });

    test("should parse and apply duration filter", () {
      final filter = AliceSearchFilter.parse("duration:100");
      expect(filter.duration, "100");
      expect(filter.apply(call), true);

      final filter2 = AliceSearchFilter.parse("duration:200");
      expect(filter2.apply(call), false);
      
      final filter3 = AliceSearchFilter.parse("duration:>100");
      expect(filter3.apply(call), true);
      
      final filter4 = AliceSearchFilter.parse("duration:<100");
      expect(filter4.apply(call), false);
      
      final filter5 = AliceSearchFilter.parse("duration:=150");
      expect(filter5.apply(call), true);
    });

    test("should handle case-insensitive keys", () {
      final filter = AliceSearchFilter.parse("Method:GET STATUS:200");
      expect(filter.method, "get");
      expect(filter.status, "200");
      expect(filter.apply(call), true);
    });

    test("should parse and apply plain text search", () {
      final filter = AliceSearchFilter.parse("users");
      expect(filter.text, "users");
      expect(filter.apply(call), true);

      final filter2 = AliceSearchFilter.parse("customers");
      expect(filter2.apply(call), false);
    });

    test("should combine filters and text search", () {
      final filter = AliceSearchFilter.parse("status:200 method:GET users");
      expect(filter.status, "200");
      expect(filter.method, "get");
      expect(filter.text, "users");
      expect(filter.apply(call), true);

      final filter2 = AliceSearchFilter.parse("status:200 method:POST users");
      expect(filter2.apply(call), false);
    });

    test("should handle empty query", () {
      final filter = AliceSearchFilter.parse("");
      expect(filter.apply(call), true);
    });
  });
}
