import 'package:alice/model/alice_export_result.dart';

class FileSaveHelper {
  static Future<AliceExportResult> saveCallsToFileIo({
    required String fileName,
    required Future<String> Function() buildAliceLog,
    required Iterable<String> Function() buildCallLogs,
  }) async {
    return AliceExportResult(
      success: false,
      error: AliceExportResultError.file,
    );
  }
}
