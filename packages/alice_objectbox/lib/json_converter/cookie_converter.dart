import 'dart:io' show Cookie;

import 'package:json_annotation/json_annotation.dart';

class CookieConverter implements JsonConverter<Cookie, String> {
  const CookieConverter();

  static const CookieConverter instance = CookieConverter();

  @override
  Cookie fromJson(String json) => Cookie.fromSetCookieValue(json);

  @override
  String toJson(Cookie object) => object.toString();
}
