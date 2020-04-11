import 'dart:io';

import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';

class AliceHttpRequest {
  int size = 0;
  DateTime time = DateTime.now();
  Map<String, dynamic> headers = Map();
  dynamic body = "";
  String contentType = "";
  List<Cookie> cookies = List();
  Map<String, dynamic> queryParameters = Map();
  List<AliceFormDataFile> formDataFiles;
  List<AliceFormDataField> formDataFields;
}
