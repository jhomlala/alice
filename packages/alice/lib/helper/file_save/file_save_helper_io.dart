import 'dart:io';
import 'package:alice/model/alice_export_result.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:path_provider/path_provider.dart';

class FileSaveHelper {
  static Future<AliceExportResult> saveCallsToFileIo({
    required String fileName,
    required Future<String> Function() buildAliceLog,
    required Iterable<String> Function() buildCallLogs,
  }) async {
    try {
      final Directory externalDir = await getApplicationCacheDirectory();
      final File file = File('${externalDir.path}/$fileName')..createSync();
      final IOSink sink = file.openWrite(mode: FileMode.append)
        ..write(await buildAliceLog());
      for (final String callLog in buildCallLogs()) {
        sink.write(callLog);
      }
      await sink.flush();
      await sink.close();
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
