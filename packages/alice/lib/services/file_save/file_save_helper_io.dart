import 'dart:io';
import 'package:alice/model/alice_export_result.dart';
import 'package:alice/utils/alice_utils.dart';
import 'package:path_provider/path_provider.dart';

class FileSaveHelper {
  static Future<AliceExportResult> saveContentToFile({
    required String fileName,
    required String content,
  }) async {
    try {
      final Directory externalDir = await getApplicationCacheDirectory();
      final File file = File('${externalDir.path}/$fileName')..createSync();
      await file.writeAsString(content);
      return AliceExportResult(success: true, path: file.path);
    } catch (exception) {
      AliceUtils.log(exception.toString());
      return AliceExportResult(
        success: false,
        error: AliceExportResultError.file,
      );
    }
  }
}
