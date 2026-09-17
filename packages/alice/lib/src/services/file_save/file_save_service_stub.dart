import 'package:alice/src/model/export_result.dart';

class FileSaveService {
  static Future<ExportResult> saveContentToFile({
    required String fileName,
    required String content,
  }) async {
    return ExportResult(success: false, error: ExportResultError.file);
  }
}
