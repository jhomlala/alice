// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';

/// Definition of http error data holder.
class AliceHttpError extends Equatable {
  dynamic error;
  StackTrace? stackTrace;

  @override
  List<Object?> get props => [error, stackTrace];
}
