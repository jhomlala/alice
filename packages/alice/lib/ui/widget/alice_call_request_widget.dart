import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/widget/alice_base_call_details_widget.dart';
import 'package:alice/utils/alice_scroll_behavior.dart';
import 'package:flutter/material.dart';

class AliceCallRequestWidget extends StatefulWidget {
  final AliceHttpCall call;

  const AliceCallRequestWidget(this.call, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _AliceCallRequestWidget();
  }
}

class _AliceCallRequestWidget
    extends AliceBaseCallDetailsWidgetState<AliceCallRequestWidget> {
  AliceHttpCall get _call => widget.call;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [
      getListRow('Started:', _call.request?.time.toString()),
      getListRow('Bytes sent:', formatBytes(_call.request?.size ?? 0)),
      getListRow('Content type:', getContentType(_call.request?.headers)),
    ];

    final dynamic body = _call.request?.body;
    final String bodyContent = body != null
        ? formatBody(body, getContentType(_call.request?.headers))
        : 'Body is empty';
    rows.add(getListRow('Body:', bodyContent));

    final List<AliceFormDataField>? formDataFields =
        _call.request?.formDataFields;
    if (formDataFields?.isNotEmpty ?? false) {
      rows.add(getListRow('Form data fields: ', ''));
      rows.addAll([
        for (final AliceFormDataField field in formDataFields!)
          getListRow('   • ${field.name}:', field.value)
      ]);
    }

    final List<AliceFormDataFile>? formDataFiles = _call.request!.formDataFiles;
    if (formDataFiles?.isNotEmpty ?? false) {
      rows.add(getListRow('Form data files: ', ''));
      rows.addAll([
        for (final AliceFormDataFile file in formDataFiles!)
          getListRow(
            '   • ${file.fileName}:',
            '${file.contentType} / ${file.length} B',
          )
      ]);
    }

    final Map<String, dynamic>? headers = _call.request?.headers;
    final String headersContent =
        headers?.isEmpty ?? true ? 'Headers are empty' : '';
    rows.add(getListRow('Headers: ', headersContent));
    rows.addAll([
      for (final MapEntry<String, dynamic> header
          in _call.request?.headers.entries ?? [])
        getListRow('   • ${header.key}:', header.value.toString())
    ]);

    final Map<String, dynamic>? queryParameters =
        _call.request?.queryParameters;
    final String queryParametersContent =
        queryParameters?.isEmpty ?? true ? 'Query parameters are empty' : '';
    rows.add(getListRow('Query Parameters: ', queryParametersContent));
    rows.addAll([
      for (final MapEntry<String, dynamic> qParam
          in _call.request?.queryParameters.entries ?? [])
        getListRow('   • ${qParam.key}:', qParam.value.toString())
    ]);

    return Container(
      padding: const EdgeInsets.all(6),
      child: ScrollConfiguration(
        behavior: AliceScrollBehavior(),
        child: ListView(children: rows),
      ),
    );
  }
}
