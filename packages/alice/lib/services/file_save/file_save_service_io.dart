import 'dart:io';
import 'package:alice/model/export_result.dart';
import 'package:alice/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

class FileSaveService {
  static Future<ExportResult> saveContentToFile({
    required String fileName,
    required String content,
  }) async {
    try {
      final Directory externalDir = await getApplicationCacheDirectory();
      final File file = File('${externalDir.path}/$fileName')..createSync();
      await file.writeAsString(content);
      return ExportResult(success: true, path: file.path);
    } catch (exception) {
      Utils.log(exception.toString());
      return ExportResult(success: false, error: ExportResultError.file);
    }
  }
}
