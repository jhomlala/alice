// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';

/// Definition of http response data holder.
class AliceHttpResponse extends Equatable {
  int? status = 0;
  int size = 0;
  DateTime time = DateTime.now();
  dynamic body;
  Map<String, String>? headers;

  @override
  List<Object?> get props => [
        status,
        size,
        time,
        body,
        headers,
      ];
}
