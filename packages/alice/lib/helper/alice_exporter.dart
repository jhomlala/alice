import 'package:alice/model/alice_http_call.dart';
import 'package:material_ui/material_ui.dart';

abstract interface class AliceExporter {
  /// Returns the file extension this exporter produces (e.g. 'txt', 'har').
  String get fileExtension;

  /// Generates the full export content as a string.
  Future<String> generate({
    required BuildContext? context,
    required List<AliceHttpCall> calls,
  });
}
