// ignore_for_file: use_build_context_synchronously

import 'dart:convert' show JsonEncoder;
import 'dart:io' show Directory, File, FileMode, IOSink;

import 'package:alice/core/alice_utils.dart';
import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/helper/operating_system.dart';
import 'package:alice/model/alice_export_result.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:alice/utils/curl.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class AliceExportHelper {
  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');
  static const String _fileName = "alice_log";

  /// Format log based on [call] and tries to share it.
  static Future<AliceExportResult> shareCall({
    required BuildContext context,
    required AliceHttpCall call,
  }) async {
    final callLog = await AliceExportHelper.buildFullCallLog(
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
      ),
    );

    return AliceExportResult(success: true);
  }

  /// Format log based on [calls] and saves it to file.
  static Future<AliceExportResult> saveCallsToFile(
    BuildContext context,
    List<AliceHttpCall> calls,
  ) async {
    final bool permissionStatus = await _getPermissionStatus();
    if (!permissionStatus) {
      final bool status = await _requestPermission();
      if (!status) {
        return AliceExportResult(
          success: false,
          error: AliceExportResultError.permission,
        );
      }
    }

    return await _saveToFile(context, calls);
  }

  /// Returns current storage permission status. Checks permission for iOS
  /// For other platforms it returns true.
  static Future<bool> _getPermissionStatus() async {
    if (OperatingSystem.isIOS) {
      return Permission.storage.status.isGranted;
    } else {
      return true;
    }
  }

  /// Requests permissions for storage for iOS. For other platforms it doesn't
  /// make any action and returns true.
  static Future<bool> _requestPermission() async {
    if (OperatingSystem.isIOS) {
      return Permission.storage.request().isGranted;
    } else {
      return true;
    }
  }

  /// Saves [calls] to file. For android it uses external storage directory and
  /// for ios it uses application documents directory.
  static Future<AliceExportResult> _saveToFile(
    BuildContext context,
    List<AliceHttpCall> calls,
  ) async {
    try {
      if (calls.isEmpty) {
        return AliceExportResult(
          success: false,
          error: AliceExportResultError.empty,
        );
      }

      final Directory externalDir = await getApplicationCacheDirectory();
      final String fileName =
          '${_fileName}_${DateTime.now().millisecondsSinceEpoch}.txt';
      final File file = File('${externalDir.path}/$fileName')..createSync();
      final IOSink sink = file.openWrite(mode: FileMode.append)
        ..write(await _buildAliceLog(context: context));
      for (final AliceHttpCall call in calls) {
        sink.write(_buildCallLog(context: context, call: call));
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

  /// Builds log string based on data collected from package info.
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

  /// Build log string based on [call].
  static String _buildCallLog({
    required BuildContext context,
    required AliceHttpCall call,
  }) {
    final StringBuffer stringBuffer =
        StringBuffer()..writeAll([
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
      '${context.i18n(AliceTranslationKey.saveLogRequestBody)} ${AliceParser.formatBody(context: context, body: call.request?.body, contentType: call.request?.contentType)}\n',
      '--------------------------------------------\n',
      '${context.i18n(AliceTranslationKey.saveLogResponse)}\n',
      '--------------------------------------------\n',
      '${context.i18n(AliceTranslationKey.saveLogResponseTime)} ${call.response?.time}\n',
      '${context.i18n(AliceTranslationKey.saveLogResponseStatus)} ${call.response?.status}\n',
      '${context.i18n(AliceTranslationKey.saveLogResponseSize)} ${AliceConversionHelper.formatBytes(call.response?.size ?? 0)}\n',
      '${context.i18n(AliceTranslationKey.saveLogResponseHeaders)} ${_encoder.convert(call.response?.headers)}\n',
      '${context.i18n(AliceTranslationKey.saveLogResponseBody)} ${AliceParser.formatBody(context: context, body: call.response?.body, contentType: AliceParser.getContentType(context: context, headers: call.response?.headers))}\n',
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
          '${context.i18n(AliceTranslationKey.saveLogStackTrace)}: ${call.error?.stackTrace}\n',
        );
      }
    }

    stringBuffer.writeAll([
      '--------------------------------------------\n',
      '${context.i18n(AliceTranslationKey.saveLogCurl)}\n',
      '--------------------------------------------\n',
      Curl.getCurlCommand(call),
      '\n',
      '==============================================\n',
      '\n',
    ]);

    return stringBuffer.toString();
  }

  /// Builds full call log string (package info log and call log).
  static Future<String?> buildFullCallLog({
    required BuildContext context,
    required AliceHttpCall call,
  }) async {
    try {
      return await _buildAliceLog(context: context) +
          _buildCallLog(call: call, context: context);
    } catch (exception) {
      AliceUtils.log("Failed to generate call log: $exception");
      return null;
    }
  }
}
