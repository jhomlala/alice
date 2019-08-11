import 'dart:convert';

import 'package:flutter/material.dart';

abstract class AliceBaseCallDetailsWidget extends StatelessWidget {
  final JsonEncoder encoder = new JsonEncoder.withIndent('  ');

  Widget getListRow(String name, String value) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          Padding(padding: EdgeInsets.only(left: 5)),
          Flexible(
              fit: FlexFit.loose,
              child: Text(
                value,
                overflow: TextOverflow.clip,
              )),
          Padding(
            padding: EdgeInsets.only(bottom: 18),
          )
        ]);
  }

  String formatBytes(int bytes) {
    return "$bytes B";
  }

  String formatDuration(int duration) {
    return "$duration ms";
  }

  String formatBody(dynamic body, String contentType) {
    var bodyContent = "Body is empty";
    if (body != null) {
      if (contentType == null ||
          !contentType.toLowerCase().contains("application/json")) {
        return body.toString();
      } else {
        if (body is String && body.contains("\n")) {
          bodyContent = body;
        } else {
          bodyContent = encoder.convert(body);
        }
      }
    }
    return bodyContent;
  }

  String getContentType(Map<String, dynamic> headers) {
    if (headers != null) {
      if (headers.containsKey("content-type")) {
        return headers["content-type"];
      }
      if (headers.containsKey("Content-Type")) {
        return headers["Content-Type"];
      }
    }
    return "???";
  }
}
