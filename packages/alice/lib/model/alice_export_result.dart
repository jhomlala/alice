class AliceExportResult {
  final bool success;
  final AliceExportResultError? error;
  final String? path;

  AliceExportResult({
    required this.success,
    this.error,
    this.path,
  });
}

enum AliceExportResultError {
  logGenerate,
  empty,
  permission,
  unknown,
}
