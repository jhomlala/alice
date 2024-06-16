import 'dart:convert' show JsonEncoder;

import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:flutter/material.dart';

abstract class AliceBaseCallDetailsWidgetState<T extends StatefulWidget>
    extends State<T> {
  final JsonEncoder encoder = const JsonEncoder.withIndent('  ');

  Widget getListRow(String name, String? value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 5),
          ),
          Flexible(
            child: value != null
                ? SelectableText(
                    value,
                  )
                : const SizedBox(),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 18),
          ),
        ],
      );

  Widget getExpandableListRow(String name, String value) => Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          tilePadding: const EdgeInsets.all(0),
          children: [
            SelectableText(
              value,
            ),
          ],
        ),
      );

  String formatBytes(int bytes) => AliceConversionHelper.formatBytes(bytes);

  String formatDuration(int duration) =>
      AliceConversionHelper.formatTime(duration);

  String formatBody(dynamic body, String? contentType) =>
      AliceParser.formatBody(body, contentType);

  String? getContentType(Map<String, dynamic>? headers) =>
      AliceParser.getContentType(headers);
}
