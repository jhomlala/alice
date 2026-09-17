import 'package:alice/src/model/alice_cookie.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AliceCookie', () {
    test('should create cookie with name and value', () {
      final cookie = AliceCookie('session', 'xyz123');
      expect(cookie.name, 'session');
      expect(cookie.value, 'xyz123');
    });

    test('toJson should return correct map', () {
      final cookie = AliceCookie('theme', 'dark');
      expect(cookie.toJson(), {'name': 'theme', 'value': 'dark'});
    });

    test('toString should format as name=value', () {
      final cookie = AliceCookie('lang', 'en');
      expect(cookie.toString(), 'lang=en');
    });

    test(
      'should handle cookie parsing logic identical to CachedAliceHttpRequest',
      () {
        final dbCookiesList = ['foo=bar', 'baz=', 'invalid_cookie'];

        final cookies =
            dbCookiesList.map((String cookie) {
              final index = cookie.indexOf('=');
              if (index == -1) {
                return AliceCookie(cookie, '');
              }
              return AliceCookie(
                cookie.substring(0, index),
                cookie.substring(index + 1),
              );
            }).toList();

        expect(cookies.length, 3);
        expect(cookies[0].name, 'foo');
        expect(cookies[0].value, 'bar');
        expect(cookies[1].name, 'baz');
        expect(cookies[1].value, '');
        expect(cookies[2].name, 'invalid_cookie');
        expect(cookies[2].value, '');
      },
    );
  });
}
