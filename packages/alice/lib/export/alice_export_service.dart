// ignore_for_file: use_build_context_synchronously

import 'package:alice/export/alice_exporter.dart';
import 'package:alice/services/permission/alice_permission_service.dart';
import 'package:alice/services/share/alice_share_service.dart';
import 'package:alice/export/alice_text_exporter.dart';
import 'package:alice/services/file_save/file_save_service.dart';
import 'package:alice/model/alice_export_result.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_loading_dialog.dart';
import 'package:alice/utils/curl.dart';
import 'package:material_ui/material_ui.dart';

class AliceExportService {
  static const String _fileName = "alice_log";

  static Future<AliceExportResult> shareCall({
    required BuildContext context,
    required AliceHttpCall call,
    Rect? sharePositionOrigin,
  }) async {
    AliceLoadingDialog.show(context);
    await Future.delayed(Duration.zero);
    try {
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

      await AliceShareService.share(
        context: context,
        text: callLog,
        subject: context.i18n(AliceTranslationKey.emailSubject),
        sharePositionOrigin: sharePositionOrigin,
      );

      return AliceExportResult(success: true);
    } finally {
      AliceLoadingDialog.hide(context);
    }
  }

  static Future<AliceExportResult> shareCurlCommand({
    required BuildContext context,
    required AliceHttpCall call,
    Rect? sharePositionOrigin,
  }) async {
    final curl = Curl.getCurlCommand(call);
    await AliceShareService.share(
      context: context,
      text: curl,
      subject: context.i18n(AliceTranslationKey.emailSubject),
      sharePositionOrigin: sharePositionOrigin,
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
        await AlicePermissionService.getPermissionStatus();
    if (!permissionStatus) {
      final bool status = await AlicePermissionService.requestPermission();
      if (!status) {
        return AliceExportResult(
          success: false,
          error: AliceExportResultError.permission,
        );
      }
    }

    AliceLoadingDialog.show(context);
    await Future.delayed(Duration.zero);
    try {
      final String content = await exporter.generate(
        context: context,
        calls: calls,
      );
      final String fileName =
          '${_fileName}_${DateTime.now().millisecondsSinceEpoch}.${exporter.fileExtension}';

      return await FileSaveService.saveContentToFile(
        fileName: fileName,
        content: content,
      );
    } finally {
      AliceLoadingDialog.hide(context);
    }
  }
}
