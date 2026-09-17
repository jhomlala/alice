/// Model of export result.
class ExportResult {
  final bool success;
  final ExportResultError? error;
  final String? path;

  ExportResult({required this.success, this.error, this.path});
}

/// Definition of all possible export errors.
enum ExportResultError { logGenerate, empty, permission, file }
