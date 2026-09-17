import 'package:alice/src/utils/conversion_utils.dart';
import 'package:alice/src/model/alice_http_call.dart';
import 'package:alice/src/model/translation.dart';
import 'package:alice/src/ui/call_details/widget/call_list_row.dart';
import 'package:alice/src/ui/common/context_ext.dart';
import 'package:alice/src/utils/alice_parser.dart';
import 'package:alice/src/ui/common/scroll_behavior.dart';
import 'package:alice/src/ui/common/json_viewer.dart';
import 'package:alice/src/utils/num_comparison.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen which displays information about HTTP call response.
class CallResponseScreen extends StatelessWidget {
  const CallResponseScreen({super.key, required this.call});

  final AliceHttpCall call;

  @override
  Widget build(BuildContext context) {
    if (!call.loading) {
      return Container(
        padding: const EdgeInsets.all(6),
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: SelectionArea(
            child: ListView(
              children: [
                _GeneralDataColumn(call: call),
                _HeaderDataColumn(call: call),
                _BodyDataColumn(call: call),
                const SizedBox(height: 64),
              ],
            ),
          ),
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
}

/// Column which displays general information like received time and bytes
/// count.
class _GeneralDataColumn extends StatelessWidget {
  final AliceHttpCall call;

  const _GeneralDataColumn({required this.call});

  @override
  Widget build(BuildContext context) {
    final int? status = call.response?.status;
    final String statusText = status == -1
        ? context.i18n(TranslationKey.callResponseError)
        : '$status';

    return Column(
      children: [
        CallListRow(
          name: context.i18n(TranslationKey.callResponseReceived),
          value: call.response?.time.toString(),
        ),
        CallListRow(
          name: context.i18n(TranslationKey.callResponseBytesReceived),
          value: ConversionUtils.formatBytes(call.response?.size ?? 0),
        ),
        CallListRow(
          name: context.i18n(TranslationKey.callResponseStatus),
          value: statusText,
        ),
      ],
    );
  }
}

/// Widget which renders column with headers of [call].
class _HeaderDataColumn extends StatelessWidget {
  final AliceHttpCall call;

  const _HeaderDataColumn({required this.call});

  @override
  Widget build(BuildContext context) {
    final Map<String, String>? headers = call.response?.headers;
    final String headersContent = headers?.isEmpty ?? true
        ? context.i18n(TranslationKey.callResponseHeadersEmpty)
        : '';

    return Column(
      children: [
        CallListRow(
          name: context.i18n(TranslationKey.callResponseHeaders),
          value: headersContent,
        ),
        for (final MapEntry<String, String> header in headers?.entries ?? [])
          CallListRow(
            name: '   • ${header.key}:',
            value: header.value.toString(),
          ),
      ],
    );
  }
}

/// Widget which renders column with body of [call].
class _BodyDataColumn extends StatefulWidget {
  const _BodyDataColumn({required this.call});

  final AliceHttpCall call;

  @override
  State<_BodyDataColumn> createState() => _BodyDataColumnState();
}

class _BodyDataColumnState extends State<_BodyDataColumn> {
  static const String _imageContentType = 'image';
  static const String _videoContentType = 'video';
  static const String _jsonContentType = 'json';
  static const String _xmlContentType = 'xml';
  static const String _textContentType = 'text';

  static const int _largeOutputSize = 100000;
  bool _showLargeBody = false;
  bool _showUnsupportedBody = false;

  AliceHttpCall get call => widget.call;

  @override
  Widget build(BuildContext context) {
    if (_isImageResponse()) {
      return _ImageBody(call: call);
    } else if (_isVideoResponse()) {
      return _VideoBody(call: call);
    } else if (_isTextResponse()) {
      if (_isLargeResponseBody()) {
        return _LargeTextBody(
          showLargeBody: _showLargeBody,
          call: call,
          onShowLargeBodyPressed: onShowLargeBodyPressed,
        );
      } else {
        return _TextBody(call: call);
      }
    } else {
      return _UnknownBody(
        call: call,
        showUnsupportedBody: _showUnsupportedBody,
        onShowUnsupportedBodyPressed: onShowUnsupportedBodyPressed,
      );
    }
  }

  /// Checks whether content type of response is image.
  bool _isImageResponse() {
    return _getContentTypeOfResponse()!.toLowerCase().contains(
      _imageContentType,
    );
  }

  /// Checks whether content type of response is video
  bool _isVideoResponse() {
    return _getContentTypeOfResponse()!.toLowerCase().contains(
      _videoContentType,
    );
  }

  /// Checks whether content type of response is text.
  bool _isTextResponse() {
    final responseContentTypeLowerCase = _getContentTypeOfResponse()!
        .toLowerCase();

    return responseContentTypeLowerCase.contains(_jsonContentType) ||
        responseContentTypeLowerCase.contains(_xmlContentType) ||
        responseContentTypeLowerCase.contains(_textContentType);
  }

  /// Parses headers and returns content type of response. It may return null.
  String? _getContentTypeOfResponse() {
    return AliceParser.getContentType(
      context: context,
      headers: call.response?.headers,
    );
  }

  /// Checks whether response body is large (more than [_largeOutputSize].
  bool _isLargeResponseBody() {
    if (_getContentTypeOfResponse()?.toLowerCase().contains('json') ?? false) {
      return false; // JsonViewer handles large payloads efficiently
    }

    final dynamic body = call.response?.body;
    if (body is String) {
      return body.length > _largeOutputSize;
    }
    if (body is List || body is Map) {
      return false; // Lists/Maps are usually JSON, but if not, avoid expensive .toString()
    }

    return body?.toString().length.gt(_largeOutputSize) ?? false;
  }

  /// Called when show large body has been pressed.
  void onShowLargeBodyPressed() {
    setState(() {
      _showLargeBody = true;
    });
  }

  /// Called when show unsupported body has been pressed.
  void onShowUnsupportedBodyPressed() {
    setState(() {
      _showUnsupportedBody = true;
    });
  }
}

/// Widget which renders body as image.
class _ImageBody extends StatelessWidget {
  const _ImageBody({required this.call});

  final AliceHttpCall call;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              context.i18n(TranslationKey.callResponseBodyImage),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Image.network(
          call.uri,
          fit: BoxFit.fill,
          headers: _buildRequestHeaders(),
          loadingBuilder:
              (
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
    );
  }

  /// Builds request headers to access the image.
  Map<String, String> _buildRequestHeaders() {
    final requestHeaders = <String, String>{};
    if (call.request?.headers != null) {
      requestHeaders.addAll(
        call.request!.headers.map(
          (String key, dynamic value) => MapEntry(key, value.toString()),
        ),
      );
    }
    return requestHeaders;
  }
}

/// Widget which renders large body as a text.
class _LargeTextBody extends StatelessWidget {
  const _LargeTextBody({
    required this.showLargeBody,
    required this.call,
    required this.onShowLargeBodyPressed,
  });

  final bool showLargeBody;
  final AliceHttpCall call;
  final void Function() onShowLargeBodyPressed;

  @override
  Widget build(BuildContext context) {
    if (showLargeBody) {
      return _TextBody(call: call);
    } else {
      return Column(
        children: [
          CallListRow(
            name: context.i18n(TranslationKey.callResponseBody),
            value:
                '${context.i18n(TranslationKey.callResponseTooLargeToShow)}'
                '(${call.response?.body.toString().length ?? 0} B)',
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onShowLargeBodyPressed,
            child: Text(context.i18n(TranslationKey.callResponseBodyShow)),
          ),
          Text(context.i18n(TranslationKey.callResponseLargeBodyShowWarning)),
        ],
      );
    }
  }
}

/// Widget which renders body as a text.
class _TextBody extends StatelessWidget {
  const _TextBody({required this.call});

  final AliceHttpCall call;

  @override
  Widget build(BuildContext context) {
    final Map<String, String>? headers = call.response?.headers;
    final String? contentType = AliceParser.getContentType(
      context: context,
      headers: headers,
    );
    final bool isJson =
        contentType != null && contentType.toLowerCase().contains('json');

    if (isJson && call.response?.body != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.i18n(TranslationKey.callResponseBody),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          JsonViewer(call.response?.body),
        ],
      );
    }

    final String bodyContent = AliceParser.formatBody(
      context: context,
      body: call.response?.body,
      contentType: AliceParser.getContentType(
        context: context,
        headers: headers,
      ),
    );
    return CallListRow(
      name: context.i18n(TranslationKey.callResponseBody),
      value: bodyContent,
    );
  }
}

/// Widget which renders body as video.
class _VideoBody extends StatelessWidget {
  const _VideoBody({required this.call});

  final AliceHttpCall call;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              context.i18n(TranslationKey.callResponseBodyVideo),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          child: Text(
            context.i18n(TranslationKey.callResponseBodyVideoWebBrowser),
          ),
          onPressed: () async {
            await launchUrl(Uri.parse(call.uri));
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Widget which renders unknown body message.
class _UnknownBody extends StatelessWidget {
  static const _contentType = "[contentType]";

  const _UnknownBody({
    required this.call,
    required this.showUnsupportedBody,
    required this.onShowUnsupportedBodyPressed,
  });

  final AliceHttpCall call;
  final bool showUnsupportedBody;
  final void Function() onShowUnsupportedBodyPressed;

  @override
  Widget build(BuildContext context) {
    final Map<String, String>? headers = call.response?.headers;
    final String contentType =
        AliceParser.getContentType(context: context, headers: headers) ??
        context.i18n(TranslationKey.callResponseHeadersUnknown);

    if (showUnsupportedBody) {
      final bodyContent = AliceParser.formatBody(
        context: context,
        body: call.response?.body,
        contentType: AliceParser.getContentType(
          context: context,
          headers: headers,
        ),
      );
      return CallListRow(
        name: context.i18n(TranslationKey.callResponseBody),
        value: bodyContent,
      );
    } else {
      return Column(
        children: [
          CallListRow(
            name: context.i18n(TranslationKey.callResponseBody),
            value: context
                .i18n(TranslationKey.callResponseBodyUnknown)
                .replaceAll(_contentType, contentType),
          ),
          TextButton(
            onPressed: onShowUnsupportedBodyPressed,
            child: Text(
              context.i18n(TranslationKey.callResponseBodyUnknownShow),
            ),
          ),
        ],
      );
    }
  }
}
