// ignore_for_file: use_build_context_synchronously

import 'package:alice/export/exporter.dart';
import 'package:alice/services/permission/permission_service.dart';
import 'package:alice/services/share/share_service.dart';
import 'package:alice/export/text_exporter.dart';
import 'package:alice/services/file_save/file_save_service.dart';
import 'package:alice/model/export_result.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/translation.dart';
import 'package:alice/ui/common/context_ext.dart';
import 'package:alice/ui/common/loading_dialog.dart';
import 'package:alice/utils/curl.dart';
import 'package:material_ui/material_ui.dart';

class ExportService {
  static const String _fileName = "alice_log";

  static Future<ExportResult> shareCall({
    required BuildContext context,
    required AliceHttpCall call,
    Rect? sharePositionOrigin,
  }) async {
    LoadingDialog.show(context);
    await Future.delayed(Duration.zero);
    try {
      final callLog = await TextExporter().buildFullCallLog(
        call: call,
        context: context,
      );

      if (callLog == null) {
        return ExportResult(
          success: false,
          error: ExportResultError.logGenerate,
        );
      }

      await ShareService.share(
        context: context,
        text: callLog,
        subject: context.i18n(TranslationKey.emailSubject),
        sharePositionOrigin: sharePositionOrigin,
      );

      return ExportResult(success: true);
    } finally {
      LoadingDialog.hide(context);
    }
  }

  static Future<ExportResult> shareCurlCommand({
    required BuildContext context,
    required AliceHttpCall call,
    Rect? sharePositionOrigin,
  }) async {
    final curl = Curl.getCurlCommand(call);
    await ShareService.share(
      context: context,
      text: curl,
      subject: context.i18n(TranslationKey.emailSubject),
      sharePositionOrigin: sharePositionOrigin,
    );

    return ExportResult(success: true);
  }

  /// Format log based on [calls] and saves it to file using [exporter].
  static Future<ExportResult> exportCalls({
    required BuildContext context,
    required List<AliceHttpCall> calls,
    required Exporter exporter,
  }) async {
    if (calls.isEmpty) {
      return ExportResult(success: false, error: ExportResultError.empty);
    }

    final bool permissionStatus = await PermissionService.getPermissionStatus();
    if (!permissionStatus) {
      final bool status = await PermissionService.requestPermission();
      if (!status) {
        return ExportResult(
          success: false,
          error: ExportResultError.permission,
        );
      }
    }

    LoadingDialog.show(context);
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
      LoadingDialog.hide(context);
    }
  }
}
