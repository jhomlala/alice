import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/call_details/widget/alice_call_list_row.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:alice/ui/common/alice_scroll_behavior.dart';
import 'package:alice/utils/num_comparison.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen which displays information about HTTP call response.
class AliceCallResponseScreen extends StatelessWidget {
  const AliceCallResponseScreen({super.key, required this.call});

  final AliceHttpCall call;

  @override
  Widget build(BuildContext context) {
    if (!call.loading) {
      return Container(
        padding: const EdgeInsets.all(6),
        child: ScrollConfiguration(
          behavior: AliceScrollBehavior(),
          child: ListView(children: [
            _GeneralDataColumn(call: call),
            _HeaderDataColumn(call: call),
            _BodyDataColumn(call: call)
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
        ? context.i18n(AliceTranslationKey.callResponseError)
        : '$status';

    return Column(
      children: [
        AliceCallListRow(
            name: context.i18n(AliceTranslationKey.callResponseReceived),
            value: call.response?.time.toString()),
        AliceCallListRow(
          name: context.i18n(AliceTranslationKey.callResponseBytesReceived),
          value: AliceConversionHelper.formatBytes(call.response?.size ?? 0),
        ),
        AliceCallListRow(
          name: context.i18n(AliceTranslationKey.callResponseStatus),
          value: statusText,
        ),
      ],
    );
  }
}

class _HeaderDataColumn extends StatelessWidget {
  final AliceHttpCall call;

  const _HeaderDataColumn({required this.call});

  @override
  Widget build(BuildContext context) {
    final Map<String, String>? headers = call.response?.headers;
    final String headersContent = headers?.isEmpty ?? true
        ? context.i18n(AliceTranslationKey.callResponseHeadersEmpty)
        : '';

    return Column(
      children: [
        AliceCallListRow(
            name: context.i18n(AliceTranslationKey.callResponseHeaders),
            value: headersContent),
        for (final MapEntry<String, String> header in headers?.entries ?? [])
          AliceCallListRow(
            name: '   • ${header.key}:',
            value: header.value.toString(),
          )
      ],
    );
  }
}

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
      return _ImageBody(
        call: call,
      );
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
    return AliceBodyParser.getContentType(
        context: context, headers: call.response?.headers);
  }

  bool _isLargeResponseBody() =>
      call.response?.body.toString().length.gt(_largeOutputSize) ?? false;

  void onShowLargeBodyPressed() {
    setState(() {
      _showLargeBody = true;
    });
  }

  void onShowUnsupportedBodyPressed() {
    setState(() {
      _showUnsupportedBody = true;
    });
  }
}

class _ImageBody extends StatelessWidget {
  const _ImageBody({
    required this.call,
  });

  final AliceHttpCall call;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              context.i18n(AliceTranslationKey.callResponseBodyImage),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Image.network(
          call.uri,
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
    );
  }

  Map<String, String> _buildRequestHeaders() {
    final requestHeaders = <String, String>{};
    if (call.request?.headers != null) {
      requestHeaders.addAll(
        call.request!.headers.map(
          (String key, dynamic value) => MapEntry(
            key,
            value.toString(),
          ),
        ),
      );
    }
    return requestHeaders;
  }
}

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
      return Column(children: [
        AliceCallListRow(
          name: context.i18n(AliceTranslationKey.callResponseBody),
          value:
              '${context.i18n(AliceTranslationKey.callResponseTooLargeToShow)}'
              '(${call.response?.body.toString().length ?? 0} B)',
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onShowLargeBodyPressed,
          child: Text(
            context.i18n(
              AliceTranslationKey.callResponseBodyShow,
            ),
          ),
        ),
        Text(
          context.i18n(
            AliceTranslationKey.callResponseLargeBodyShowWarning,
          ),
        ),
      ]);
    }
  }
}

class _TextBody extends StatelessWidget {
  const _TextBody({required this.call});

  final AliceHttpCall call;

  @override
  Widget build(BuildContext context) {
    final Map<String, String>? headers = call.response?.headers;
    final String bodyContent = AliceBodyParser.formatBody(
      context: context,
      body: call.response?.body,
      contentType:
          AliceBodyParser.getContentType(context: context, headers: headers),
    );
    return AliceCallListRow(
        name: context.i18n(AliceTranslationKey.callResponseBody),
        value: bodyContent);
  }
}

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
              context.i18n(AliceTranslationKey.callResponseBodyVideo),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          child: Text(context
              .i18n(AliceTranslationKey.callResponseBodyVideoWebBrowser)),
          onPressed: () async {
            await launchUrl(Uri.parse(call.uri));
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _UnknownBody extends StatelessWidget {
  const _UnknownBody(
      {required this.call,
      required this.showUnsupportedBody,
      required this.onShowUnsupportedBodyPressed});

  final AliceHttpCall call;
  final bool showUnsupportedBody;
  final void Function() onShowUnsupportedBodyPressed;

  @override
  Widget build(BuildContext context) {
    final Map<String, String>? headers = call.response?.headers;
    final String contentType =
        AliceBodyParser.getContentType(context: context, headers: headers) ??
            context.i18n(AliceTranslationKey.callResponseHeadersUnknown);

    if (showUnsupportedBody) {
      final bodyContent = AliceBodyParser.formatBody(
        context: context,
        body: call.response?.body,
        contentType:
            AliceBodyParser.getContentType(context: context, headers: headers),
      );
      return AliceCallListRow(
          name: context.i18n(AliceTranslationKey.callResponseBody),
          value: bodyContent);
    } else {
      return Column(
        children: [
          AliceCallListRow(
            name: context.i18n(AliceTranslationKey.callResponseBody),
            value: context
                .i18n(AliceTranslationKey.callResponseBodyUnknown)
                .replaceAll(
                  "[contentType]",
                  contentType,
                ),
          ),
          TextButton(
            onPressed: onShowUnsupportedBodyPressed,
            child: Text(
              context.i18n(
                AliceTranslationKey.callResponseBodyUnknownShow,
              ),
            ),
          ),
        ],
      );
    }
  }
}
