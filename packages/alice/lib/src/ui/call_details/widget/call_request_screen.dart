import 'package:alice/src/utils/conversion_utils.dart';
import 'package:alice/src/model/alice_form_data_file.dart';
import 'package:alice/src/model/alice_form_data_field.dart';
import 'package:alice/src/model/alice_http_call.dart';
import 'package:alice/src/model/translation.dart';
import 'package:alice/src/ui/call_details/widget/call_list_row.dart';
import 'package:alice/src/ui/common/context_ext.dart';
import 'package:alice/src/utils/alice_parser.dart';
import 'package:alice/src/ui/common/scroll_behavior.dart';
import 'package:alice/src/ui/common/json_viewer.dart';
import 'package:material_ui/material_ui.dart';

/// Screen which displays information about call request: content, transfer,
/// headers.
class CallRequestScreen extends StatelessWidget {
  final AliceHttpCall call;

  const CallRequestScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [
      CallListRow(
        name: context.i18n(TranslationKey.callRequestStarted),
        value: call.request?.time.toString(),
      ),
      CallListRow(
        name: context.i18n(TranslationKey.callRequestBytesSent),
        value: ConversionUtils.formatBytes(call.request?.size ?? 0),
      ),
      CallListRow(
        name: context.i18n(TranslationKey.callRequestContentType),
        value: AliceParser.getContentType(
          context: context,
          headers: call.request?.headers,
        ),
      ),
    ];

    final String? contentType = AliceParser.getContentType(
      context: context,
      headers: call.request?.headers,
    );
    final bool isJson =
        contentType != null && contentType.toLowerCase().contains('json');

    if (isJson && call.request?.body != null && call.request?.body is! Stream) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.i18n(TranslationKey.callRequestBody),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              JsonViewer(call.request?.body),
            ],
          ),
        ),
      );
    } else {
      rows.add(
        CallListRow(
          name: context.i18n(TranslationKey.callRequestBody),
          value: _getBodyContent(context: context),
        ),
      );
    }

    final List<AliceFormDataField>? formDataFields =
        call.request?.formDataFields;
    if (formDataFields?.isNotEmpty ?? false) {
      rows.add(
        CallListRow(
          name: context.i18n(TranslationKey.callRequestFormDataFields),
          value: '',
        ),
      );
      rows.addAll([
        for (final AliceFormDataField field in formDataFields!)
          CallListRow(name: '   • ${field.name}:', value: field.value),
      ]);
    }

    final List<AliceFormDataFile>? formDataFiles = call.request!.formDataFiles;
    if (formDataFiles?.isNotEmpty ?? false) {
      rows.add(
        CallListRow(
          name: context.i18n(TranslationKey.callRequestFormDataFiles),
          value: '',
        ),
      );
      rows.addAll([
        for (final AliceFormDataFile file in formDataFiles!)
          CallListRow(
            name: '   • ${file.fileName}:',
            value: '${file.contentType} / ${file.length} B',
          ),
      ]);
    }

    final Map<String, dynamic>? headers = call.request?.headers;
    final String headersContent = headers?.isEmpty ?? true
        ? context.i18n(TranslationKey.callRequestHeadersEmpty)
        : '';
    rows.add(
      CallListRow(
        name: context.i18n(TranslationKey.callRequestHeaders),
        value: headersContent,
      ),
    );
    rows.addAll([
      for (final MapEntry<String, dynamic> header in headers?.entries ?? [])
        CallListRow(
          name: '   • ${header.key}:',
          value: header.value.toString(),
        ),
    ]);

    final Map<String, dynamic>? queryParameters = call.request?.queryParameters;
    final String queryParametersContent = queryParameters?.isEmpty ?? true
        ? context.i18n(TranslationKey.callRequestQueryParametersEmpty)
        : '';
    rows.add(
      CallListRow(
        name: context.i18n(TranslationKey.callRequestQueryParameters),
        value: queryParametersContent,
      ),
    );
    rows.addAll([
      for (final MapEntry<String, dynamic> queryParam
          in queryParameters?.entries ?? [])
        CallListRow(
          name: '   • ${queryParam.key}:',
          value: queryParam.value.toString(),
        ),
    ]);
    rows.add(const SizedBox(height: 64));

    return Container(
      padding: const EdgeInsets.all(6),
      child: ScrollConfiguration(
        behavior: CustomScrollBehavior(),
        child: SelectionArea(child: ListView(children: rows)),
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
        : context.i18n(TranslationKey.callRequestBodyEmpty);
  }
}
