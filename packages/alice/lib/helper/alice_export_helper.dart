// ignore_for_file: use_build_context_synchronously

import 'package:alice/helper/alice_exporter.dart';
import 'package:alice/helper/alice_permission_helper.dart';
import 'package:alice/helper/alice_text_exporter.dart';
import 'package:alice/helper/file_save/file_save_helper.dart';
import 'package:alice/model/alice_export_result.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/utils/curl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

class AliceExportHelper {
  static const String _fileName = "alice_log";

  static Future<AliceExportResult> shareCall({
    required BuildContext context,
    required AliceHttpCall call,
    Rect? sharePositionOrigin,
  }) async {
    final callLog = await AliceTextExporter().buildFullCallLog(
      call: call,
      context: context,
    );

    if (callLog == null) {
      return AliceExportResult(
        success: false,
        error: AliceExportResultError.logGenerate,
      );
    }

    await SharePlus.instance.share(
      ShareParams(
        text: callLog,
        subject: context.i18n(AliceTranslationKey.emailSubject),
        sharePositionOrigin: sharePositionOrigin,
      ),
    );

    return AliceExportResult(success: true);
  }

  static Future<AliceExportResult> shareCurlCommand({
    required BuildContext context,
    required AliceHttpCall call,
    Rect? sharePositionOrigin,
  }) async {
    final curl = Curl.getCurlCommand(call);
    await SharePlus.instance.share(
      ShareParams(
        text: curl,
        subject: context.i18n(AliceTranslationKey.emailSubject),
        sharePositionOrigin: sharePositionOrigin,
      ),
    );

    return AliceExportResult(success: true);
  }

  /// Format log based on [calls] and saves it to file using [exporter].
  static Future<AliceExportResult> exportCalls({
    required BuildContext context,
    required List<AliceHttpCall> calls,
    required AliceExporter exporter,
  }) async {
    if (calls.isEmpty) {
      return AliceExportResult(
        success: false,
        error: AliceExportResultError.empty,
      );
    }

    final bool permissionStatus =
        await AlicePermissionHelper.getPermissionStatus();
    if (!permissionStatus) {
      final bool status = await AlicePermissionHelper.requestPermission();
      if (!status) {
        return AliceExportResult(
          success: false,
          error: AliceExportResultError.permission,
        );
      }
    }

    final String content = await exporter.generate(context, calls);
    final String fileName =
        '${_fileName}_${DateTime.now().millisecondsSinceEpoch}.${exporter.fileExtension}';

    return FileSaveHelper.saveContentToFile(
      fileName: fileName,
      content: content,
    );
  }
}
