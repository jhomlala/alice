import 'package:equatable/equatable.dart';

/// Definition of http error data holder.
class AliceHttpError with EquatableMixin {
  dynamic error;
  StackTrace? stackTrace;

  @override
  List<Object?> get props => [error, stackTrace];
}
