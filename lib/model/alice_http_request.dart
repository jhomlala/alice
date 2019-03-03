import 'dart:io';

class AliceHttpRequest {
  int size = 0;
  DateTime time = DateTime.now();
  Map<String, dynamic> headers = Map();
  String body = "";
  String contentType = "";
  List<Cookie> cookies = List();
}
