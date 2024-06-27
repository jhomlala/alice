import 'dart:io' show Cookie;

import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';

/// Definition of http request data holder.
class AliceHttpRequest {
  int size = 0;
  DateTime time = DateTime.now();
  Map<String, dynamic> headers = <String, dynamic>{};
  dynamic body = '';
  String? contentType = '';
  List<Cookie> cookies = [];
  Map<String, dynamic> queryParameters = <String, dynamic>{};
  List<AliceFormDataFile>? formDataFiles;
  List<AliceFormDataField>? formDataFields;
}
