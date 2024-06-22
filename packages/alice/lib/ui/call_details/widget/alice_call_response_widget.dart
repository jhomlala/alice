import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/call_details/widget/alice_call_list_row.dart';
import 'package:alice/utils/alice_constants.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:alice/utils/alice_scroll_behavior.dart';
import 'package:alice/utils/num_comparison.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AliceCallResponseWidget extends StatefulWidget {
  final AliceHttpCall call;

  const AliceCallResponseWidget(this.call, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _AliceCallResponseWidgetState();
  }
}

class _AliceCallResponseWidgetState extends State<AliceCallResponseWidget> {
  static const String _imageContentType = 'image';
  static const String _videoContentType = 'video';
  static const String _jsonContentType = 'json';
  static const String _xmlContentType = 'xml';
  static const String _textContentType = 'text';

  static const int _kLargeOutputSize = 100000;
  bool _showLargeBody = false;
  bool _showUnsupportedBody = false;

  AliceHttpCall get _call => widget.call;

  @override
  Widget build(BuildContext context) {
    if (!_call.loading) {
      return Container(
        padding: const EdgeInsets.all(6),
        child: ScrollConfiguration(
          behavior: AliceScrollBehavior(),
          child: ListView(children: [
            ..._buildGeneralDataRows(),
            ..._buildHeadersRows(),
            ..._buildBodyRows(),
          ]),
        ),
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator(), Text('Awaiting response...')],
        ),
      );
    }
  }

  List<Widget> _buildGeneralDataRows() {
    final rows = <Widget>[
      AliceCallListRow(
          name: 'Received:', value: _call.response?.time.toString()),
      AliceCallListRow(
          name: 'Bytes received:',
          value: AliceConversionHelper.formatBytes(_call.response?.size ?? 0)),
    ];

    final int? status = _call.response?.status;
    final String statusText = status == -1 ? 'Error' : '$status';

    rows.add(AliceCallListRow(name: 'Status:', value: statusText));
    return rows;
  }

  List<Widget> _buildHeadersRows() {
    final List<Widget> rows = [];
    final Map<String, String>? headers = _call.response?.headers;
    final String headersContent =
        headers?.isEmpty ?? true ? 'Headers are empty' : '';
    rows.add(AliceCallListRow(name: 'Headers: ', value: headersContent));
    rows.addAll([
      for (final MapEntry<String, String> header
          in _call.response?.headers?.entries ?? [])
        AliceCallListRow(
            name: '   • ${header.key}:', value: header.value.toString())
    ]);

    return rows;
  }

  List<Widget> _buildBodyRows() => [
        if (_isImageResponse())
          ..._buildImageBodyRows()
        else if (_isVideoResponse())
          ..._buildVideoBodyRows()
        else if (_isTextResponse()) ...[
          if (_isLargeResponseBody())
            ..._buildLargeBodyTextRows()
          else
            ..._buildTextBodyRows(),
        ] else
          ..._buildUnknownBodyRows()
      ];

  List<Widget> _buildImageBodyRows() {
    return [
      Column(
        children: [
          const Row(
            children: [
              Text(
                'Body: Image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Image.network(
            _call.uri,
            fit: BoxFit.fill,
            headers: _buildRequestHeaders(),
            loadingBuilder: (
              BuildContext context,
              Widget child,
              ImageChunkEvent? loadingProgress,
            ) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ];
  }

  List<Widget> _buildLargeBodyTextRows() {
    final rows = <Widget>[];
    if (_showLargeBody) {
      return _buildTextBodyRows();
    } else {
      rows
        ..add(
          AliceCallListRow(
            name: 'Body:',
            value: 'Too large to show '
                '(${_call.response?.body.toString().length ?? 0} Bytes)',
          ),
        )
        ..add(const SizedBox(height: 8))
        ..add(
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.all<Color>(AliceConstants.lightRed),
            ),
            onPressed: () {
              setState(() {
                _showLargeBody = true;
              });
            },
            child: const Text('Show body'),
          ),
        )
        ..add(const SizedBox(height: 8))
        ..add(const Text('Warning! It will take some time to render output.'));
    }
    return rows;
  }

  List<Widget> _buildTextBodyRows() {
    final List<Widget> rows = [];
    final Map<String, String>? headers = _call.response?.headers;
    final String bodyContent = AliceParser.formatBody(
        _call.response?.body, AliceParser.getContentType(headers));
    rows.add(AliceCallListRow(name: 'Body:', value: bodyContent));
    return rows;
  }

  List<Widget> _buildVideoBodyRows() {
    final rows = <Widget>[
      const Row(
        children: [
          Text(
            'Body: Video',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      const SizedBox(height: 8),
      TextButton(
        child: const Text('Open video in web browser'),
        onPressed: () async {
          await launchUrl(Uri.parse(_call.uri));
        },
      ),
      const SizedBox(height: 8),
    ];

    return rows;
  }

  List<Widget> _buildUnknownBodyRows() {
    final List<Widget> rows = [];
    final Map<String, String>? headers = _call.response?.headers;
    final String contentType =
        AliceParser.getContentType(headers) ?? '<unknown>';

    if (_showUnsupportedBody) {
      final bodyContent = AliceParser.formatBody(
          _call.response?.body, AliceParser.getContentType(headers));
      rows.add(AliceCallListRow(name: 'Body:', value: bodyContent));
    } else {
      rows
        ..add(
          AliceCallListRow(
              name: 'Body:',
              value:
                  'Unsupported body. Alice can render video/image/text body. '
                  "Response has Content-Type: $contentType which can't be "
                  "handled. If you're feeling lucky you can try button below "
                  'to try render body as text, but it may fail.'),
        )
        ..add(
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.all<Color>(AliceConstants.lightRed),
            ),
            onPressed: () {
              setState(() {
                _showUnsupportedBody = true;
              });
            },
            child: const Text('Show unsupported body'),
          ),
        );
    }
    return rows;
  }

  Map<String, String> _buildRequestHeaders() {
    final requestHeaders = <String, String>{};
    if (_call.request?.headers != null) {
      requestHeaders.addAll(
        _call.request!.headers.map(
          (String key, dynamic value) => MapEntry(
            key,
            value.toString(),
          ),
        ),
      );
    }
    return requestHeaders;
  }

  bool _isImageResponse() {
    return _getContentTypeOfResponse()!
        .toLowerCase()
        .contains(_imageContentType);
  }

  bool _isVideoResponse() {
    return _getContentTypeOfResponse()!
        .toLowerCase()
        .contains(_videoContentType);
  }

  bool _isTextResponse() {
    final responseContentTypeLowerCase =
        _getContentTypeOfResponse()!.toLowerCase();

    return responseContentTypeLowerCase.contains(_jsonContentType) ||
        responseContentTypeLowerCase.contains(_xmlContentType) ||
        responseContentTypeLowerCase.contains(_textContentType);
  }

  String? _getContentTypeOfResponse() {
    return AliceParser.getContentType(_call.response?.headers);
  }

  bool _isLargeResponseBody() =>
      _call.response?.body.toString().length.gt(_kLargeOutputSize) ?? false;
}
