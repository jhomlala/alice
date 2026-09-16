// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:alice/core/alice_utils.dart';
import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/helper/alice_exporter.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:alice/utils/curl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alice/utils/package_info/package_info_provider.dart';

class AliceTextExporter implements AliceExporter {
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
    final packageInfo = await getPackageInfo();

    return '${context.i18n(AliceTranslationKey.saveHeaderTitle)}\n'
        '${context.i18n(AliceTranslationKey.saveHeaderAppName)}  ${packageInfo.appName}\n'
        '${context.i18n(AliceTranslationKey.saveHeaderPackage)} ${packageInfo.packageName}\n'
        '${context.i18n(AliceTranslationKey.saveHeaderTitle)} ${packageInfo.version}\n'
        '${context.i18n(AliceTranslationKey.saveHeaderBuildNumber)} ${packageInfo.buildNumber}\n'
        '${context.i18n(AliceTranslationKey.saveHeaderGenerated)} ${DateTime.now().toIso8601String()}\n'
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
    } else {
      // Fallback if context is null (minimal info)
      stringBuffer.writeAll([
        'ID: ${call.id}\n',
        'Server: ${call.server}\n',
        'Method: ${call.method}\n',
        'Endpoint: ${call.endpoint}\n',
        'Duration: ${AliceConversionHelper.formatTime(call.duration)}\n',
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
      AliceUtils.log("Failed to generate call log: $exception");
      return null;
    }
  }
}
