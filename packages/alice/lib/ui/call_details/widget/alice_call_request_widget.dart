import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/call_details/widget/alice_call_list_row.dart';
import 'package:alice/utils/alice_parser.dart';
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

class _AliceCallRequestWidget extends State<AliceCallRequestWidget> {
  AliceHttpCall get _call => widget.call;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [
      AliceCallListRow(name: 'Started:', value: _call.request?.time.toString()),
      AliceCallListRow(
          name: 'Bytes sent:',
          value: AliceConversionHelper.formatBytes(_call.request?.size ?? 0)),
      AliceCallListRow(
          name: 'Content type:',
          value: AliceParser.getContentType(_call.request?.headers)),
    ];

    rows.add(AliceCallListRow(name: 'Body:', value: _getBodyContent()));

    final List<AliceFormDataField>? formDataFields =
        _call.request?.formDataFields;
    if (formDataFields?.isNotEmpty ?? false) {
      rows.add(const AliceCallListRow(name: 'Form data fields: ', value: ''));
      rows.addAll([
        for (final AliceFormDataField field in formDataFields!)
          AliceCallListRow(name: '   • ${field.name}:', value: field.value)
      ]);
    }

    final List<AliceFormDataFile>? formDataFiles = _call.request!.formDataFiles;
    if (formDataFiles?.isNotEmpty ?? false) {
      rows.add(const AliceCallListRow(name: 'Form data files: ', value: ''));
      rows.addAll([
        for (final AliceFormDataFile file in formDataFiles!)
          AliceCallListRow(
            name: '   • ${file.fileName}:',
            value: '${file.contentType} / ${file.length} B',
          )
      ]);
    }

    final Map<String, dynamic>? headers = _call.request?.headers;
    final String headersContent =
        headers?.isEmpty ?? true ? 'Headers are empty' : '';
    rows.add(AliceCallListRow(name: 'Headers: ', value: headersContent));
    rows.addAll([
      for (final MapEntry<String, dynamic> header in headers?.entries ?? [])
        AliceCallListRow(
            name: '   • ${header.key}:', value: header.value.toString())
    ]);

    final Map<String, dynamic>? queryParameters =
        _call.request?.queryParameters;
    final String queryParametersContent =
        queryParameters?.isEmpty ?? true ? 'Query parameters are empty' : '';
    rows.add(AliceCallListRow(
        name: 'Query Parameters: ', value: queryParametersContent));
    rows.addAll([
      for (final MapEntry<String, dynamic> queryParam
          in queryParameters?.entries ?? [])
        AliceCallListRow(
            name: '   • ${queryParam.key}:', value: queryParam.value.toString())
    ]);

    return Container(
      padding: const EdgeInsets.all(6),
      child: ScrollConfiguration(
        behavior: AliceScrollBehavior(),
        child: ListView(children: rows),
      ),
    );
  }

  String _getBodyContent() {
    final dynamic body = _call.request?.body;
    return body != null
        ? AliceParser.formatBody(
            body, AliceParser.getContentType(_call.request?.headers))
        : 'Body is empty';
  }
}
