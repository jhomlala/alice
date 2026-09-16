import 'package:alice/model/alice_export_result.dart';

class FileSaveService {
  static Future<AliceExportResult> saveContentToFile({
    required String fileName,
    required String content,
  }) async {
    return AliceExportResult(
      success: false,
      error: AliceExportResultError.file,
    );
  }
}
