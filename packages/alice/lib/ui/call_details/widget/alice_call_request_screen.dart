import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/call_details/widget/alice_call_list_row.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:alice/ui/common/alice_scroll_behavior.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Screen which displays information about call request: content, transfer,
/// headers.
class AliceCallRequestScreen extends StatelessWidget {
  final AliceHttpCall call;

  const AliceCallRequestScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [
      AliceCallListRow(
        name: context.i18n(AliceTranslationKey.callRequestStarted),
        value: call.request?.time.toString(),
      ),
      AliceCallListRow(
        name: context.i18n(AliceTranslationKey.callRequestBytesSent),
        value: AliceConversionHelper.formatBytes(call.request?.size ?? 0),
      ),
      AliceCallListRow(
        name: context.i18n(AliceTranslationKey.callRequestContentType),
        value: AliceParser.getContentType(
          context: context,
          headers: call.request?.headers,
        ),
      ),
    ];

    rows.add(
      AliceCallListRow(
        name: context.i18n(AliceTranslationKey.callRequestBody),
        value: _getBodyContent(context: context),
      ),
    );

    final List<AliceFormDataField>? formDataFields =
        call.request?.formDataFields;
    if (formDataFields?.isNotEmpty ?? false) {
      rows.add(
        AliceCallListRow(
          name: context.i18n(AliceTranslationKey.callRequestFormDataFields),
          value: '',
        ),
      );
      rows.addAll([
        for (final AliceFormDataField field in formDataFields!)
          AliceCallListRow(name: '   • ${field.name}:', value: field.value),
      ]);
    }

    final List<AliceFormDataFile>? formDataFiles = call.request!.formDataFiles;
    if (formDataFiles?.isNotEmpty ?? false) {
      rows.add(
        AliceCallListRow(
          name: context.i18n(AliceTranslationKey.callRequestFormDataFiles),
          value: '',
        ),
      );
      rows.addAll([
        for (final AliceFormDataFile file in formDataFiles!)
          AliceCallListRow(
            name: '   • ${file.fileName}:',
            value: '${file.contentType} / ${file.length} B',
          ),
      ]);
    }

    final Map<String, dynamic>? headers = call.request?.headers;
    final String headersContent =
        headers?.isEmpty ?? true
            ? context.i18n(AliceTranslationKey.callRequestHeadersEmpty)
            : '';
    rows.add(
      AliceCallListRow(
        name: context.i18n(AliceTranslationKey.callRequestHeaders),
        value: headersContent,
      ),
    );
    rows.addAll([
      for (final MapEntry<String, dynamic> header in headers?.entries ?? [])
        AliceCallListRow(
          name: '   • ${header.key}:',
          value: header.value.toString(),
        ),
    ]);

    final Map<String, dynamic>? queryParameters = call.request?.queryParameters;
    final String queryParametersContent =
        queryParameters?.isEmpty ?? true
            ? context.i18n(AliceTranslationKey.callRequestQueryParametersEmpty)
            : '';
    rows.add(
      AliceCallListRow(
        name: context.i18n(AliceTranslationKey.callRequestQueryParameters),
        value: queryParametersContent,
      ),
    );
    rows.addAll([
      for (final MapEntry<String, dynamic> queryParam
          in queryParameters?.entries ?? [])
        AliceCallListRow(
          name: '   • ${queryParam.key}:',
          value: queryParam.value.toString(),
        ),
    ]);

    return Container(
      padding: const EdgeInsets.all(6),
      child: ScrollConfiguration(
        behavior: AliceScrollBehavior(),
        child: ListView(children: rows),
      ),
    );
  }

  /// Returns body content formatted.
  String _getBodyContent({required BuildContext context}) {
    final dynamic body = call.request?.body;
    return body != null
        ? AliceParser.formatBody(
          context: context,
          body: body,
          contentType: AliceParser.getContentType(
            context: context,
            headers: call.request?.headers,
          ),
        )
        : context.i18n(AliceTranslationKey.callRequestBodyEmpty);
  }
}
