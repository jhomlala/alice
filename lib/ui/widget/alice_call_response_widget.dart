import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/widget/alice_base_call_details_widget.dart';
import 'package:alice/utils/alice_constants.dart';
import 'package:alice/utils/alice_scroll_behavior.dart';
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

class _AliceCallResponseWidgetState
    extends AliceBaseCallDetailsWidgetState<AliceCallResponseWidget> {
  static const _imageContentType = 'image';
  static const _videoContentType = 'video';
  static const _jsonContentType = 'json';
  static const _xmlContentType = 'xml';
  static const _textContentType = 'text';

  static const _kLargeOutputSize = 100000;
  bool _showLargeBody = false;
  bool _showUnsupportedBody = false;

  AliceHttpCall get _call => widget.call;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    if (!_call.loading) {
      rows
        ..addAll(_buildGeneralDataRows())
        ..addAll(_buildHeadersRows())
        ..addAll(_buildBodyRows());

      return Container(
        padding: const EdgeInsets.all(6),
        child: ScrollConfiguration(
          behavior: AliceScrollBehavior(),
          child: ListView(children: rows),
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
      getListRow('Received:', _call.response!.time.toString()),
      getListRow('Bytes received:', formatBytes(_call.response!.size)),
    ];

    final status = _call.response!.status;
    var statusText = '$status';
    if (status == -1) {
      statusText = 'Error';
    }

    rows.add(getListRow('Status:', statusText));
    return rows;
  }

  List<Widget> _buildHeadersRows() {
    final rows = <Widget>[];
    final headers = _call.response!.headers;
    var headersContent = 'Headers are empty';
    if (headers != null && headers.isNotEmpty) {
      headersContent = '';
    }
    rows.add(getListRow('Headers: ', headersContent));
    if (_call.response!.headers != null) {
      _call.response!.headers!.forEach((header, value) {
        rows.add(getListRow('   • $header:', value));
      });
    }
    return rows;
  }

  List<Widget> _buildBodyRows() {
    final rows = <Widget>[];
    if (_isImageResponse()) {
      rows.addAll(_buildImageBodyRows());
    } else if (_isVideoResponse()) {
      rows.addAll(_buildVideoBodyRows());
    } else if (_isTextResponse()) {
      if (_isLargeResponseBody()) {
        rows.addAll(_buildLargeBodyTextRows());
      } else {
        rows.addAll(_buildTextBodyRows());
      }
    } else {
      rows.addAll(_buildUnknownBodyRows());
    }

    return rows;
  }

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
          getListRow(
            'Body:',
            'Too large to show '
                '(${_call.response!.body.toString().length} Bytes)',
          ),
        )
        ..add(const SizedBox(height: 8))
        ..add(
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(AliceConstants.lightRed),
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
    final rows = <Widget>[];
    final headers = _call.response!.headers;
    final bodyContent =
        formatBody(_call.response!.body, getContentType(headers));
    rows.add(getListRow('Body:', bodyContent));
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
    final rows = <Widget>[];
    final headers = _call.response!.headers;
    final contentType = getContentType(headers) ?? '<unknown>';

    if (_showUnsupportedBody) {
      final bodyContent =
          formatBody(_call.response!.body, getContentType(headers));
      rows.add(getListRow('Body:', bodyContent));
    } else {
      rows
        ..add(
          getListRow(
              'Body:',
              'Unsupported body. Alice can render video/image/text body. '
                  "Response has Content-Type: $contentType which can't be "
                  "handled. If you're feeling lucky you can try button below "
                  'to try render body as text, but it may fail.'),
        )
        ..add(
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(AliceConstants.lightRed),
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
          (String key, dynamic value) {
            return MapEntry(key, value.toString());
          },
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
    return getContentType(_call.response!.headers);
  }

  bool _isLargeResponseBody() {
    return _call.response!.body != null &&
        _call.response!.body.toString().length > _kLargeOutputSize;
  }
}
