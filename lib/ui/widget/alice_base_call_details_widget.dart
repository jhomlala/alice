import 'dart:convert';

import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class AliceBaseCallDetailsWidgetState<T extends StatefulWidget>
    extends State<T> with AutomaticKeepAliveClientMixin {
  final JsonEncoder encoder = const JsonEncoder.withIndent('  ');

  Widget getListRow(String name, String value) {
    return Builder(builder: (context) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SelectableText(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 5),
          ),
          Expanded(
            child: SelectableText(
              value,
            ),
          ),
          SizedBox(
            width: 8,
          ),
          IconButton(
            icon: Icon(Icons.copy),
            padding: EdgeInsets.zero,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Copy successful!!'),
                duration: Duration(milliseconds: 500),
              ));
            },
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 18),
          )
        ],
      );
    });
  }

  String formatBytes(int bytes) => AliceConversionHelper.formatBytes(bytes);

  String formatDuration(int duration) =>
      AliceConversionHelper.formatTime(duration);

  String formatBody(dynamic body, String? contentType) =>
      AliceParser.formatBody(body, contentType);

  String? getContentType(Map<String, dynamic>? headers) =>
      AliceParser.getContentType(headers);
}
