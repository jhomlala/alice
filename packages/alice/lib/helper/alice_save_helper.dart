// ignore_for_file: use_build_context_synchronously

import 'dart:convert' show JsonEncoder;
import 'dart:io' show Directory, File, FileMode, IOSink, Platform;

import 'package:alice/core/alice_utils.dart';
import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/helper/operating_system.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_dialog.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:alice/utils/curl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AliceSaveHelper {
  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  /// Top level method used to save calls to file
  static void saveCalls(
    BuildContext context,
    List<AliceHttpCall> calls,
  ) {
    _checkPermissions(context, calls);
  }

  static Future<bool> _getPermissionStatus() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return Permission.storage.status.isGranted;
    } else {
      return true;
    }
  }

  static Future<bool> _requestPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return Permission.storage.request().isGranted;
    } else {
      return true;
    }
  }

  static Future<void> _checkPermissions(
    BuildContext context,
    List<AliceHttpCall> calls,
  ) async {
    final bool permissionStatus = await _getPermissionStatus();

    if (!context.mounted) return;

    if (permissionStatus) {
      await _saveToFile(context, calls);
    } else {
      final bool status = await _requestPermission();

      if (!context.mounted) return;

      if (status) {
        await _saveToFile(context, calls);
      } else {
        AliceGeneralDialog.show(
          context: context,
          title:
              context.i18n(AliceTranslationKey.saveDialogPermissionErrorTitle),
          description: context
              .i18n(AliceTranslationKey.saveDialogPermissionErrorDescription),
        );
      }
    }
  }

  static Future<String> _saveToFile(
    BuildContext context,
    List<AliceHttpCall> calls,
  ) async {
    try {
      if (calls.isEmpty) {
        AliceGeneralDialog.show(
          context: context,
          title: context.i18n(AliceTranslationKey.saveDialogEmptyErrorTitle),
          description:
              context.i18n(AliceTranslationKey.saveDialogEmptyErrorDescription),
        );
        return '';
      }

      final Directory? externalDir = switch (Platform.operatingSystem) {
        OperatingSystem.android => await getExternalStorageDirectory(),
        OperatingSystem.ios => await getApplicationDocumentsDirectory(),
        _ => await getApplicationCacheDirectory(),
      };

      if (externalDir != null) {
        final String fileName =
            'alice_log_${DateTime.now().millisecondsSinceEpoch}.txt';
        final File file = File('${externalDir.path}/$fileName')..createSync();
        final IOSink sink = file.openWrite(mode: FileMode.append)
          ..write(await _buildAliceLog(context: context));
        for (final AliceHttpCall call in calls) {
          sink.write(_buildCallLog(context: context, call: call));
        }
        await sink.flush();
        await sink.close();

        if (context.mounted) {
          AliceGeneralDialog.show(
            context: context,
            title: context.i18n(AliceTranslationKey.saveSuccessTitle),
            description: context
                .i18n(AliceTranslationKey.saveSuccessDescription)
                .replaceAll("[path]", file.path),
            secondButtonTitle: Platform.isAndroid
                ? context.i18n(AliceTranslationKey.saveSuccessView)
                : null,
            secondButtonAction: () =>
                Platform.isAndroid ? OpenFilex.open(file.path) : null,
          );
        }

        return file.path;
      } else {
        if (context.mounted) {
          AliceGeneralDialog.show(
            context: context,
            title:
                context.i18n(AliceTranslationKey.saveDialogFileSaveErrorTitle),
            description: context
                .i18n(AliceTranslationKey.saveDialogFileSaveErrorDescription),
          );
        }
      }
    } catch (exception) {
      if (context.mounted) {
        AliceGeneralDialog.show(
          context: context,
          title: context.i18n(AliceTranslationKey.saveDialogFileSaveErrorTitle),
          description: context
              .i18n(AliceTranslationKey.saveDialogFileSaveErrorDescription),
        );
        AliceUtils.log(exception.toString());
      }
    }

    return '';
  }

  static Future<String> _buildAliceLog({required BuildContext context}) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return '${context.i18n(AliceTranslationKey.saveHeaderTitle)}\n'
        '${context.i18n(AliceTranslationKey.saveHeaderAppName)}  ${packageInfo.appName}\n'
        '${context.i18n(AliceTranslationKey.saveHeaderPackage)} ${packageInfo.packageName}\n'
        '${context.i18n(AliceTranslationKey.saveHeaderTitle)} ${packageInfo.version}\n'
        '${context.i18n(AliceTranslationKey.saveHeaderBuildNumber)} ${packageInfo.buildNumber}\n'
        '${context.i18n(AliceTranslationKey.saveHeaderGenerated)} ${DateTime.now().toIso8601String()}\n'
        '\n';
  }

  static String _buildCallLog(
      {required BuildContext context, required AliceHttpCall call}) {
    final StringBuffer stringBuffer = StringBuffer()
      ..writeAll([
        '===========================================\n',
        '${context.i18n(AliceTranslationKey.saveLogId)} ${call.id}\n',
        '============================================\n',
        '--------------------------------------------\n',
        '${context.i18n(AliceTranslationKey.saveLogGeneralData)}\n',
        '--------------------------------------------\n',
        '${context.i18n(AliceTranslationKey.saveLogServer)} ${call.server} \n',
        '${context.i18n(AliceTranslationKey.saveLogMethod)} ${call.method} \n',
        '${context.i18n(AliceTranslationKey.saveLogEndpoint)} ${call.endpoint} \n',
        '${context.i18n(AliceTranslationKey.saveLogClient)} ${call.client} \n',
        '${context.i18n(AliceTranslationKey.saveLogDuration)} ${AliceConversionHelper.formatTime(call.duration)}\n',
        '${context.i18n(AliceTranslationKey.saveLogSecured)} ${call.secure}\n',
        '${context.i18n(AliceTranslationKey.saveLogCompleted)}: ${!call.loading} \n',
        '--------------------------------------------\n',
        '${context.i18n(AliceTranslationKey.saveLogRequest)}\n',
        '--------------------------------------------\n',
        '${context.i18n(AliceTranslationKey.saveLogRequestTime)} ${call.request?.time}\n',
        '${context.i18n(AliceTranslationKey.saveLogRequestContentType)}: ${call.request?.contentType}\n',
        '${context.i18n(AliceTranslationKey.saveLogRequestCookies)} ${_encoder.convert(call.request?.cookies)}\n',
        '${context.i18n(AliceTranslationKey.saveLogRequestHeaders)} ${_encoder.convert(call.request?.headers)}\n',
      ]);

    if (call.request?.queryParameters.isNotEmpty ?? false) {
      stringBuffer.write(
        '${context.i18n(AliceTranslationKey.saveLogRequestQueryParams)} ${_encoder.convert(call.request?.queryParameters)}\n',
      );
    }

    stringBuffer.writeAll([
      '${context.i18n(AliceTranslationKey.saveLogRequestSize)} ${AliceConversionHelper.formatBytes(call.request?.size ?? 0)}\n',
      '${context.i18n(AliceTranslationKey.saveLogRequestBody)} ${AliceBodyParser.formatBody(context: context, body: call.request?.body, contentType: call.request?.contentType)}\n',
      '--------------------------------------------\n',
      '${context.i18n(AliceTranslationKey.saveLogResponse)}\n',
      '--------------------------------------------\n',
      '${context.i18n(AliceTranslationKey.saveLogResponseTime)} ${call.response?.time}\n',
      '${context.i18n(AliceTranslationKey.saveLogResponseStatus)} ${call.response?.status}\n',
      '${context.i18n(AliceTranslationKey.saveLogResponseSize)} ${AliceConversionHelper.formatBytes(call.response?.size ?? 0)}\n',
      '${context.i18n(AliceTranslationKey.saveLogResponseHeaders)} ${_encoder.convert(call.response?.headers)}\n',
      '${context.i18n(AliceTranslationKey.saveLogResponseBody)} ${AliceBodyParser.formatBody(context: context, body: call.response?.body, contentType: AliceBodyParser.getContentType(context: context, headers: call.response?.headers))}\n',
    ]);

    if (call.error != null) {
      stringBuffer.writeAll([
        '--------------------------------------------\n',
        '${context.i18n(AliceTranslationKey.saveLogError)}\n',
        '--------------------------------------------\n',
        '${context.i18n(AliceTranslationKey.saveLogError)}: ${call.error?.error}\n',
      ]);

      if (call.error?.stackTrace != null) {
        stringBuffer.write(
            '${context.i18n(AliceTranslationKey.saveLogStackTrace)}: ${call.error?.stackTrace}\n');
      }
    }

    stringBuffer.writeAll([
      '--------------------------------------------\n',
      '${context.i18n(AliceTranslationKey.saveLogCurl)}\n',
      '--------------------------------------------\n',
      getCurlCommand(call),
      '\n',
      '==============================================\n',
      '\n',
    ]);

    return stringBuffer.toString();
  }

  static Future<String> buildCallLog(
      {required BuildContext context, required AliceHttpCall call}) async {
    try {
      return await _buildAliceLog(context: context) +
          _buildCallLog(
            call: call,
            context: context,
          );
    } catch (exception) {
      return 'Failed to generate call log';
    }
  }
}
