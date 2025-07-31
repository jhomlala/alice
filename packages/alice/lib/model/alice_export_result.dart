/// Model of export result.
class AliceExportResult {
  final bool success;
  final AliceExportResultError? error;
  final String? path;

  AliceExportResult({required this.success, this.error, this.path});
}

/// Definition of all possible export errors.
enum AliceExportResultError { logGenerate, empty, permission, file }
