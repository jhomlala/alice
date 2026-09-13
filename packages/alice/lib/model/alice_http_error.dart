import 'package:equatable/equatable.dart';

/// Definition of http error data holder.
// ignore: must_be_immutable
class AliceHttpError extends Equatable {
  dynamic error;
  StackTrace? stackTrace;

  @override
  List<Object?> get props => [error, stackTrace];
}
