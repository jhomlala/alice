// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:alice/utils/utils.dart';
import 'package:alice/utils/conversion_utils.dart';
import 'package:alice/export/exporter.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/translation.dart';
import 'package:alice/ui/common/context_ext.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:alice/utils/curl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alice/services/package_info/package_info_service.dart';

class TextExporter implements Exporter {
  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  @override
  String get fileExtension => 'txt';

  @override
  Future<String> generate({
    required BuildContext? context,
    required List<AliceHttpCall> calls,
  }) async {
    final StringBuffer stringBuffer = StringBuffer();
    if (context != null) {
      stringBuffer.write(await _buildAliceLog(context: context));
    }

    for (final call in calls) {
      stringBuffer.write(_buildCallLog(context: context, call: call));
    }

    return stringBuffer.toString();
  }

  /// Builds log string based on data collected from package info.
  Future<String> _buildAliceLog({required BuildContext context}) async {
    final packageInfo = await PackageInfoService.getPackageInfo();

    return '${context.i18n(TranslationKey.saveHeaderTitle)}\n'
        '${context.i18n(TranslationKey.saveHeaderAppName)}  ${packageInfo.appName}\n'
        '${context.i18n(TranslationKey.saveHeaderPackage)} ${packageInfo.packageName}\n'
        '${context.i18n(TranslationKey.saveHeaderTitle)} ${packageInfo.version}\n'
        '${context.i18n(TranslationKey.saveHeaderBuildNumber)} ${packageInfo.buildNumber}\n'
        '${context.i18n(TranslationKey.saveHeaderGenerated)} ${DateTime.now().toIso8601String()}\n'
        '\n';
  }

  /// Build log string based on [call].
  String _buildCallLog({
    required BuildContext? context,
    required AliceHttpCall call,
  }) {
    final StringBuffer stringBuffer = StringBuffer();

    if (context != null) {
      stringBuffer.writeAll([
        '===========================================\n',
        '${context.i18n(TranslationKey.saveLogId)} ${call.id}\n',
        '============================================\n',
        '--------------------------------------------\n',
        '${context.i18n(TranslationKey.saveLogGeneralData)}\n',
        '--------------------------------------------\n',
        '${context.i18n(TranslationKey.saveLogServer)} ${call.server} \n',
        '${context.i18n(TranslationKey.saveLogMethod)} ${call.method} \n',
        '${context.i18n(TranslationKey.saveLogEndpoint)} ${call.endpoint} \n',
        '${context.i18n(TranslationKey.saveLogClient)} ${call.client} \n',
        '${context.i18n(TranslationKey.saveLogDuration)} ${ConversionUtils.formatTime(call.duration)}\n',
        '${context.i18n(TranslationKey.saveLogSecured)} ${call.secure}\n',
        '${context.i18n(TranslationKey.saveLogCompleted)}: ${!call.loading} \n',
        '--------------------------------------------\n',
        '${context.i18n(TranslationKey.saveLogRequest)}\n',
        '--------------------------------------------\n',
        '${context.i18n(TranslationKey.saveLogRequestTime)} ${call.request?.time}\n',
        '${context.i18n(TranslationKey.saveLogRequestContentType)}: ${call.request?.contentType}\n',
        '${context.i18n(TranslationKey.saveLogRequestCookies)} ${_encoder.convert(call.request?.cookies)}\n',
        '${context.i18n(TranslationKey.saveLogRequestHeaders)} ${_encoder.convert(call.request?.headers)}\n',
      ]);

      if (call.request?.queryParameters.isNotEmpty ?? false) {
        stringBuffer.write(
          '${context.i18n(TranslationKey.saveLogRequestQueryParams)} ${_encoder.convert(call.request?.queryParameters)}\n',
        );
      }

      stringBuffer.writeAll([
        '${context.i18n(TranslationKey.saveLogRequestSize)} ${ConversionUtils.formatBytes(call.request?.size ?? 0)}\n',
        '${context.i18n(TranslationKey.saveLogRequestBody)} ${AliceParser.formatBody(context: context, body: call.request?.body, contentType: call.request?.contentType)}\n',
        '--------------------------------------------\n',
        '${context.i18n(TranslationKey.saveLogResponse)}\n',
        '--------------------------------------------\n',
        '${context.i18n(TranslationKey.saveLogResponseTime)} ${call.response?.time}\n',
        '${context.i18n(TranslationKey.saveLogResponseStatus)} ${call.response?.status}\n',
        '${context.i18n(TranslationKey.saveLogResponseSize)} ${ConversionUtils.formatBytes(call.response?.size ?? 0)}\n',
        '${context.i18n(TranslationKey.saveLogResponseHeaders)} ${_encoder.convert(call.response?.headers)}\n',
        '${context.i18n(TranslationKey.saveLogResponseBody)} ${AliceParser.formatBody(context: context, body: call.response?.body, contentType: AliceParser.getContentType(context: context, headers: call.response?.headers))}\n',
      ]);

      if (call.error != null) {
        stringBuffer.writeAll([
          '--------------------------------------------\n',
          '${context.i18n(TranslationKey.saveLogError)}\n',
          '--------------------------------------------\n',
          '${context.i18n(TranslationKey.saveLogError)}: ${call.error?.error}\n',
        ]);

        if (call.error?.stackTrace != null) {
          stringBuffer.write(
            '${context.i18n(TranslationKey.saveLogStackTrace)}: ${call.error?.stackTrace}\n',
          );
        }
      }

      stringBuffer.writeAll([
        '--------------------------------------------\n',
        '${context.i18n(TranslationKey.saveLogCurl)}\n',
        '--------------------------------------------\n',
        Curl.getCurlCommand(call),
        '\n',
        '==============================================\n',
        '\n',
      ]);
    } else {
      // Fallback if context is null (minimal info)
      stringBuffer.writeAll([
        'ID: ${call.id}\n',
        'Server: ${call.server}\n',
        'Method: ${call.method}\n',
        'Endpoint: ${call.endpoint}\n',
        'Duration: ${ConversionUtils.formatTime(call.duration)}\n',
        '\n',
      ]);
    }

    return stringBuffer.toString();
  }

  /// Builds full call log string (package info log and call log).
  Future<String?> buildFullCallLog({
    required BuildContext context,
    required AliceHttpCall call,
  }) async {
    try {
      return await _buildAliceLog(context: context) +
          _buildCallLog(call: call, context: context);
    } catch (exception) {
      Utils.log("Failed to generate call log: $exception");
      return null;
    }
  }
}
