import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/utils/alice_constants.dart';
import 'package:alice/ui/widget/alice_base_call_details_widget.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class AliceCallResponseWidget extends StatefulWidget {
  final AliceHttpCall call;

  AliceCallResponseWidget(this.call)
      : assert(call != null, "call can't be null");

  @override
  State<StatefulWidget> createState() {
    return _AliceCallResponseWidgetState();
  }
}

class _AliceCallResponseWidgetState
    extends AliceBaseCallDetailsWidgetState<AliceCallResponseWidget> {
  static const _imageContentType = "image";
  static const _videoContentType = "video";
  static const _jsonContentType = "json";
  static const _xmlContentType = "xml";
  static const _textContentType = "text";

  static const _kLargeOutputSize = 100000;
  BetterPlayerController _betterPlayerController;
  bool _showLargeBody = false;
  bool _showUnsupportedBody = false;

  AliceHttpCall get _call => widget.call;

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = List();
    if (!_call.loading) {
      rows.addAll(_buildGeneralDataRows());
      rows.addAll(_buildHeadersRows());
      rows.addAll(_buildBodyRows());

      return Container(
        padding: const EdgeInsets.all(6),
        child: ListView(children: rows),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new CircularProgressIndicator(),
            Text("Awaiting response...")
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }

  List<Widget> _buildGeneralDataRows() {
    List<Widget> rows = List();
    rows.add(getListRow("Received:", _call.response.time.toString()));
    rows.add(getListRow("Bytes received:", formatBytes(_call.response.size)));

    var status = _call.response.status;
    var statusText = "$status";
    if (status == -1) {
      statusText = "Error";
    }

    rows.add(getListRow("Status:", statusText));
    return rows;
  }

  List<Widget> _buildHeadersRows() {
    List<Widget> rows = List();
    var headers = _call.response.headers;
    var headersContent = "Headers are empty";
    if (headers != null && headers.length > 0) {
      headersContent = "";
    }
    rows.add(getListRow("Headers: ", headersContent));
    if (_call.response.headers != null) {
      _call.response.headers.forEach((header, value) {
        rows.add(getListRow("   • $header:", value.toString()));
      });
    }
    return rows;
  }

  List<Widget> _buildBodyRows() {
    List<Widget> rows = List();
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
    List<Widget> rows = List();
    rows.add(
      Column(
        children: [
          Row(
            children: [
              Text(
                "Body: Image",
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
          const SizedBox(height: 8),
          Image.network(
            _call.uri,
            fit: BoxFit.fill,
            headers: _buildRequestHeaders(),
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes
                      : null,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
    return rows;
  }

  List<Widget> _buildLargeBodyTextRows() {
    List<Widget> rows = List();
    if (_showLargeBody) {
      return _buildTextBodyRows();
    } else {
      rows.add(getListRow("Body:",
          "Too large to show (${_call.response.body.toString().length} Bytes)"));
      rows.add(const SizedBox(height: 8));
      rows.add(
        RaisedButton(
          color: AliceConstants.lightRed,
          child: Text("Show body"),
          onPressed: () {
            setState(() {
              _showLargeBody = true;
            });
          },
        ),
      );
      rows.add(const SizedBox(height: 8));
      rows.add(Text("Warning! It will take some time to render output."));
    }
    return rows;
  }

  List<Widget> _buildTextBodyRows() {
    List<Widget> rows = List();
    var headers = _call.response.headers;
    var bodyContent = formatBody(_call.response.body, getContentType(headers));
    rows.add(getListRow("Body:", bodyContent));
    return rows;
  }

  List<Widget> _buildVideoBodyRows() {
    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(aspectRatio: 16 / 9, fit: BoxFit.cover),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.NETWORK,
        _call.uri,
      ),
    );

    List<Widget> rows = List();
    rows.add(
      Row(
        children: [
          Text(
            "Body: Video",
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
    rows.add(const SizedBox(height: 8));
    rows.add(
      BetterPlayer(controller: _betterPlayerController),
    );
    rows.add(const SizedBox(height: 8));
    return rows;
  }

  List<Widget> _buildUnknownBodyRows() {
    List<Widget> rows = List();
    var headers = _call.response.headers;
    var contentType = getContentType(headers) ?? "<unknown>";

    if (_showUnsupportedBody) {
      var bodyContent =
          formatBody(_call.response.body, getContentType(headers));
      rows.add(getListRow("Body:", bodyContent));
    } else {
      rows.add(getListRow(
          "Body:",
          "Unsupported body. Alice can render video/image/text body. "
              "Response has Content-Type: $contentType which can't be handled. "
              "If you're feeling lucky you can try button below to try render body"
              " as text, but it may fail."));
      rows.add(
        RaisedButton(
          child: Text("Show unsupported body"),
          color: AliceConstants.lightRed,
          onPressed: () {
            setState(() {
              _showUnsupportedBody = true;
            });
          },
        ),
      );
    }
    return rows;
  }

  Map<String, String> _buildRequestHeaders() {
    Map<String, String> requestHeaders = Map();
    if (_call?.request?.headers != null) {
      requestHeaders.addAll(
        _call.request.headers.map(
          (String key, dynamic value) {
            return MapEntry(key, value.toString());
          },
        ),
      );
    }
    return requestHeaders;
  }

  bool _isImageResponse() {
    return _getContentTypeOfResponse()
        .toLowerCase()
        .contains(_imageContentType);
  }

  bool _isVideoResponse() {
    return _getContentTypeOfResponse()
        .toLowerCase()
        .contains(_videoContentType);
  }

  bool _isTextResponse() {
    String responseContentTypeLowerCase =
        _getContentTypeOfResponse().toLowerCase();

    return responseContentTypeLowerCase.contains(_jsonContentType) ||
        responseContentTypeLowerCase.contains(_xmlContentType) ||
        responseContentTypeLowerCase.contains(_textContentType);
  }

  String _getContentTypeOfResponse() {
    return getContentType(_call.response.headers);
  }

  bool _isLargeResponseBody() {
    return _call.response.body != null &&
        _call.response.body.toString().length > _kLargeOutputSize;
  }
}
