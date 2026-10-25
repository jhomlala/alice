import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alice/src/model/translation.dart';
import 'package:alice/src/ui/common/context_ext.dart';
import 'package:alice/src/utils/alice_parser.dart';

class JsonViewer extends StatefulWidget {
  final dynamic jsonObject;
  final bool initiallyExpanded;

  const JsonViewer(
    this.jsonObject, {
    super.key,
    this.initiallyExpanded = false,
  });

  @override
  State<JsonViewer> createState() => _AliceJsonViewerState();
}

class _AliceJsonViewerState extends State<JsonViewer> {
  dynamic _parsedJson;
  bool _isParsing = false;
  String? _parseError;

  @override
  void initState() {
    super.initState();
    _initJson();
  }

  @override
  void didUpdateWidget(JsonViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jsonObject != widget.jsonObject) {
      _initJson();
    }
  }

  void _initJson() {
    if (widget.jsonObject is String) {
      final str = widget.jsonObject as String;
      if (str.length > 10000) {
        setState(() {
          _isParsing = true;
          _parseError = null;
        });
        compute(AliceParser.tryDecodeJson, str)
            .then((value) {
              if (!mounted) return;
              setState(() {
                _parsedJson = value;
                _isParsing = false;
                if (value == null) {
                  _parseError = 'Failed to parse JSON';
                }
              });
            })
            .catchError((e) {
              if (!mounted) return;
              setState(() {
                _parseError = e.toString();
                _isParsing = false;
              });
            });
      } else {
        final decoded = AliceParser.tryDecodeJson(str);
        if (decoded == null) {
          _parseError = 'Failed to parse JSON';
        } else {
          _parsedJson = decoded;
        }
      }
    } else {
      _parsedJson = widget.jsonObject;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isParsing) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(context.i18n(TranslationKey.jsonViewerParsing)),
          ],
        ),
      );
    }

    if (_parseError != null) {
      return SelectableText(
        '${context.i18n(TranslationKey.jsonViewerInvalid)}$_parseError\n\n${widget.jsonObject}',
      );
    }

    return _JsonObjectViewer(
      jsonObject: _parsedJson,
      initiallyExpanded: widget.initiallyExpanded,
      jsonPath: r'$',
    );
  }
}

class _JsonObjectViewer extends StatefulWidget {
  final dynamic jsonObject;
  final bool initiallyExpanded;
  final String? nodeKey;
  final String jsonPath;

  const _JsonObjectViewer({
    required this.jsonObject,
    this.initiallyExpanded = false,
    this.nodeKey,
    required this.jsonPath,
  });

  @override
  State<_JsonObjectViewer> createState() => _JsonObjectViewerState();
}

class _JsonObjectViewerState extends State<_JsonObjectViewer> {
  bool _isExpanded = false;
  int _listLimit = 50;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.jsonObject is Map) {
      return _MapViewer(
        map: widget.jsonObject as Map,
        nodeKey: widget.nodeKey,
        jsonPath: widget.jsonPath,
        isExpanded: _isExpanded,
        onToggle: () => setState(() => _isExpanded = !_isExpanded),
      );
    } else if (widget.jsonObject is List) {
      return _ListViewer(
        list: widget.jsonObject as List,
        nodeKey: widget.nodeKey,
        jsonPath: widget.jsonPath,
        isExpanded: _isExpanded,
        listLimit: _listLimit,
        onToggle: () => setState(() => _isExpanded = !_isExpanded),
        onShowMore: () => setState(() => _listLimit += 50),
      );
    } else {
      return _KeyValueViewer(
        nodeKey: widget.nodeKey,
        value: widget.jsonObject,
        jsonPath: widget.jsonPath,
      );
    }
  }
}

class _MapViewer extends StatelessWidget {
  final Map map;
  final String? nodeKey;
  final String jsonPath;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _MapViewer({
    required this.map,
    required this.nodeKey,
    required this.jsonPath,
    required this.isExpanded,
    required this.onToggle,
  });

  void _showContextMenu(BuildContext context, TapDownDetails details) async {
    final overlay =
        Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final copiedMessage = context.i18n(TranslationKey.jsonViewerCopied);

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'path',
          child: Text(context.i18n(TranslationKey.jsonViewerCopyPath)),
        ),
        PopupMenuItem(
          value: 'subtree',
          child: Text(context.i18n(TranslationKey.jsonViewerCopySubtree)),
        ),
      ],
    );

    if (selected == 'path') {
      await Clipboard.setData(ClipboardData(text: jsonPath));
      messenger.showSnackBar(
        SnackBar(
          content: Text(copiedMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (selected == 'subtree') {
      const encoder = JsonEncoder.withIndent('  ');
      await Clipboard.setData(ClipboardData(text: encoder.convert(map)));
      messenger.showSnackBar(
        SnackBar(
          content: Text(copiedMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (map.isEmpty) {
      return _KeyValueViewer(nodeKey: nodeKey, value: '{}', jsonPath: jsonPath);
    }
    final objectTranslation = context.i18n(TranslationKey.jsonViewerObject);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ExpandableHeader(
          text: nodeKey == null
              ? '$objectTranslation {${map.length}}'
              : '$nodeKey: {${map.length}}',
          isExpanded: isExpanded,
          onTap: onToggle,
          onSecondaryOrLongPress: (details) =>
              _showContextMenu(context, details),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: map.entries.map((e) {
                return _JsonObjectViewer(
                  nodeKey: e.key.toString(),
                  jsonObject: e.value,
                  jsonPath: '$jsonPath.${e.key}',
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _ListViewer extends StatelessWidget {
  final List list;
  final String? nodeKey;
  final String jsonPath;
  final bool isExpanded;
  final int listLimit;
  final VoidCallback onToggle;
  final VoidCallback onShowMore;

  const _ListViewer({
    required this.list,
    required this.nodeKey,
    required this.jsonPath,
    required this.isExpanded,
    required this.listLimit,
    required this.onToggle,
    required this.onShowMore,
  });

  void _showContextMenu(BuildContext context, TapDownDetails details) async {
    final overlay =
        Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final copiedMessage = context.i18n(TranslationKey.jsonViewerCopied);

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'path',
          child: Text(context.i18n(TranslationKey.jsonViewerCopyPath)),
        ),
        PopupMenuItem(
          value: 'subtree',
          child: Text(context.i18n(TranslationKey.jsonViewerCopySubtree)),
        ),
      ],
    );

    if (selected == 'path') {
      await Clipboard.setData(ClipboardData(text: jsonPath));
      messenger.showSnackBar(
        SnackBar(
          content: Text(copiedMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (selected == 'subtree') {
      const encoder = JsonEncoder.withIndent('  ');
      await Clipboard.setData(ClipboardData(text: encoder.convert(list)));
      messenger.showSnackBar(
        SnackBar(
          content: Text(copiedMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return _KeyValueViewer(nodeKey: nodeKey, value: '[]', jsonPath: jsonPath);
    }
    final arrayTranslation = context.i18n(TranslationKey.jsonViewerArray);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ExpandableHeader(
          text: nodeKey == null
              ? '$arrayTranslation [${list.length}]'
              : '$nodeKey: [${list.length}]',
          isExpanded: isExpanded,
          onTap: onToggle,
          onSecondaryOrLongPress: (details) =>
              _showContextMenu(context, details),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...list.take(listLimit).toList().asMap().entries.map((e) {
                  return _JsonObjectViewer(
                    nodeKey: '[${e.key}]',
                    jsonObject: e.value,
                    jsonPath: '$jsonPath[${e.key}]',
                  );
                }),
                if (list.length > listLimit)
                  GestureDetector(
                    onTap: onShowMore,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        context
                            .i18n(TranslationKey.jsonViewerShowMore)
                            .replaceAll(
                              '[remaining]',
                              '${list.length - listLimit}',
                            ),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ExpandableHeader extends StatelessWidget {
  final String text;
  final bool isExpanded;
  final VoidCallback onTap;
  final void Function(TapDownDetails details)? onSecondaryOrLongPress;

  const _ExpandableHeader({
    required this.text,
    required this.isExpanded,
    required this.onTap,
    this.onSecondaryOrLongPress,
  });

  @override
  Widget build(BuildContext context) {
    TapDownDetails? lastTapDown;
    return GestureDetector(
      onTapDown: (details) => lastTapDown = details,
      onTap: onTap,
      onLongPress: () {
        if (lastTapDown != null && onSecondaryOrLongPress != null) {
          onSecondaryOrLongPress!(lastTapDown!);
        }
      },
      onSecondaryTapDown: onSecondaryOrLongPress,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
              size: 20,
            ),
            Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _KeyValueViewer extends StatelessWidget {
  final String? nodeKey;
  final dynamic value;
  final String jsonPath;

  const _KeyValueViewer({
    required this.nodeKey,
    required this.value,
    required this.jsonPath,
  });

  void _showContextMenu(BuildContext context, TapDownDetails details) async {
    final overlay =
        Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final copiedMessage = context.i18n(TranslationKey.jsonViewerCopied);

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'path',
          child: Text(context.i18n(TranslationKey.jsonViewerCopyPath)),
        ),
        PopupMenuItem(
          value: 'value',
          child: Text(context.i18n(TranslationKey.jsonViewerCopyValue)),
        ),
      ],
    );

    if (selected == 'path') {
      await Clipboard.setData(ClipboardData(text: jsonPath));
      messenger.showSnackBar(
        SnackBar(
          content: Text(copiedMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (selected == 'value') {
      await Clipboard.setData(ClipboardData(text: value?.toString() ?? 'null'));
      messenger.showSnackBar(
        SnackBar(
          content: Text(copiedMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color valueColor = Colors.grey;
    String displayValue = 'null';
    if (value is String) {
      if (value == '{}' || value == '[]') {
        valueColor = Colors.grey;
        displayValue = value as String;
      } else {
        valueColor = Colors.green;
        displayValue = '"$value"';
      }
    } else if (value is num) {
      valueColor = Colors.orange;
      displayValue = value.toString();
    } else if (value is bool) {
      valueColor = Colors.blue;
      displayValue = value.toString();
    }

    TapDownDetails? lastTapDown;

    return GestureDetector(
      onTapDown: (details) => lastTapDown = details,
      onLongPress: () {
        if (lastTapDown != null) {
          _showContextMenu(context, lastTapDown!);
        }
      },
      onSecondaryTapDown: (details) => _showContextMenu(context, details),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (nodeKey != null) ...[
              Text(
                '$nodeKey: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            Flexible(
              child: Text(displayValue, style: TextStyle(color: valueColor)),
            ),
          ],
        ),
      ),
    );
  }
}
