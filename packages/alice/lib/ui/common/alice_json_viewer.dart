import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AliceJsonViewer extends StatefulWidget {
  final dynamic jsonObject;
  final bool initiallyExpanded;

  const AliceJsonViewer(this.jsonObject, {super.key, this.initiallyExpanded = false});

  @override
  State<AliceJsonViewer> createState() => _AliceJsonViewerState();
}

class _AliceJsonViewerState extends State<AliceJsonViewer> {
  dynamic _parsedJson;
  bool _isParsing = false;
  String? _parseError;

  @override
  void initState() {
    super.initState();
    _initJson();
  }

  @override
  void didUpdateWidget(AliceJsonViewer oldWidget) {
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
        compute(_decodeJson, str).then((value) {
          setState(() {
            _parsedJson = value;
            _isParsing = false;
            if (value == null) {
              _parseError = 'Failed to parse JSON';
            }
          });
        }).catchError((e) {
          setState(() {
            _parseError = e.toString();
            _isParsing = false;
          });
        });
      } else {
        try {
          _parsedJson = jsonDecode(str);
        } catch (e) {
          _parseError = e.toString();
        }
      }
    } else {
      _parsedJson = widget.jsonObject;
    }
  }

  static dynamic _decodeJson(String jsonStr) {
    try {
      return jsonDecode(jsonStr);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isParsing) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 8),
            Text('Parsing JSON...'),
          ],
        ),
      );
    }

    if (_parseError != null) {
      return SelectableText('Invalid JSON: $_parseError\n\n${widget.jsonObject}');
    }

    return _JsonObjectViewer(
      jsonObject: _parsedJson,
      initiallyExpanded: widget.initiallyExpanded,
    );
  }
}

class _JsonObjectViewer extends StatefulWidget {
  final dynamic jsonObject;
  final bool initiallyExpanded;
  final String? nodeKey;

  const _JsonObjectViewer({
    required this.jsonObject,
    this.initiallyExpanded = false,
    this.nodeKey,
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
        isExpanded: _isExpanded,
        onToggle: () => setState(() => _isExpanded = !_isExpanded),
      );
    } else if (widget.jsonObject is List) {
      return _ListViewer(
        list: widget.jsonObject as List,
        nodeKey: widget.nodeKey,
        isExpanded: _isExpanded,
        listLimit: _listLimit,
        onToggle: () => setState(() => _isExpanded = !_isExpanded),
        onShowMore: () => setState(() => _listLimit += 50),
      );
    } else {
      return _KeyValueViewer(
        nodeKey: widget.nodeKey,
        value: widget.jsonObject,
      );
    }
  }
}

class _MapViewer extends StatelessWidget {
  final Map map;
  final String? nodeKey;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _MapViewer({
    required this.map,
    required this.nodeKey,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (map.isEmpty) {
      return _KeyValueViewer(nodeKey: nodeKey, value: '{}');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ExpandableHeader(
          text: nodeKey == null ? 'Object {${map.length}}' : '$nodeKey: {${map.length}}',
          isExpanded: isExpanded,
          onTap: onToggle,
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
  final bool isExpanded;
  final int listLimit;
  final VoidCallback onToggle;
  final VoidCallback onShowMore;

  const _ListViewer({
    required this.list,
    required this.nodeKey,
    required this.isExpanded,
    required this.listLimit,
    required this.onToggle,
    required this.onShowMore,
  });

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return _KeyValueViewer(nodeKey: nodeKey, value: '[]');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ExpandableHeader(
          text: nodeKey == null ? 'Array [${list.length}]' : '$nodeKey: [${list.length}]',
          isExpanded: isExpanded,
          onTap: onToggle,
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
                  );
                }),
                if (list.length > listLimit)
                  GestureDetector(
                    onTap: onShowMore,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Show more (${list.length - listLimit} remaining)',
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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

  const _ExpandableHeader({
    required this.text,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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

  const _KeyValueViewer({
    required this.nodeKey,
    required this.value,
  });

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (nodeKey != null) ...[
            Text('$nodeKey: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
          Flexible(
            child: Text(
              displayValue,
              style: TextStyle(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

