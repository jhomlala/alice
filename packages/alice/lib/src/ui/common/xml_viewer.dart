import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alice/src/model/translation.dart';
import 'package:alice/src/ui/common/context_ext.dart';
import 'package:xml/xml.dart';

/// Collapsible tree viewer for XML response bodies.
///
/// Parses the body string on a background isolate when the payload is large,
/// then builds a widget tree that mirrors the structure of [JsonViewer].
class XmlViewer extends StatefulWidget {
  final dynamic body;

  const XmlViewer(this.body, {super.key});

  @override
  State<XmlViewer> createState() => _XmlViewerState();
}

class _XmlViewerState extends State<XmlViewer> {
  XmlDocument? _document;
  bool _isParsing = false;
  String? _parseError;

  @override
  void initState() {
    super.initState();
    _initXml();
  }

  @override
  void didUpdateWidget(XmlViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.body != widget.body) {
      _initXml();
    }
  }

  void _initXml() {
    final raw = widget.body?.toString() ?? '';
    if (raw.isEmpty) return;

    if (raw.length > 10000) {
      setState(() {
        _isParsing = true;
        _parseError = null;
        _document = null;
      });
      compute(_parseXml, raw).then((result) {
        setState(() {
          _isParsing = false;
          if (result is XmlDocument) {
            _document = result;
          } else {
            _parseError = result as String;
          }
        });
      });
    } else {
      final result = _parseXml(raw);
      if (result is XmlDocument) {
        _document = result;
      } else {
        _parseError = result as String;
      }
    }
  }

  /// Runs in a background isolate — must be a top-level function.
  static dynamic _parseXml(String raw) {
    try {
      return XmlDocument.parse(raw);
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isParsing) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(context.i18n(TranslationKey.xmlViewerParsing)),
          ],
        ),
      );
    }

    if (_parseError != null) {
      return SelectableText(
        '${context.i18n(TranslationKey.xmlViewerInvalid)}$_parseError\n\n${widget.body}',
      );
    }

    final doc = _document;
    if (doc == null) {
      return SelectableText(widget.body?.toString() ?? '');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: doc.childElements
          .map((e) => _XmlElementNode(element: e, initiallyExpanded: true))
          .toList(),
    );
  }
}

class _XmlElementNode extends StatefulWidget {
  final XmlElement element;
  final bool initiallyExpanded;

  const _XmlElementNode({
    required this.element,
    this.initiallyExpanded = false,
  });

  @override
  State<_XmlElementNode> createState() => _XmlElementNodeState();
}

class _XmlElementNodeState extends State<_XmlElementNode> {
  bool _isExpanded = false;
  int _childLimit = 50;

  XmlElement get element => widget.element;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final childElements = element.childElements.toList();
    final attrs = element.attributes;
    final hasChildren = childElements.isNotEmpty;
    final isLeaf = !hasChildren;

    if (isLeaf) {
      return _LeafNode(element: element);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ExpandableHeader(
          label: _headerLabel(context, childElements.length),
          isExpanded: _isExpanded,
          onTap: () => setState(() => _isExpanded = !_isExpanded),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (attrs.isNotEmpty) _AttributesRow(attributes: attrs),
                ...childElements
                    .take(_childLimit)
                    .map((child) => _XmlElementNode(element: child)),
                if (childElements.length > _childLimit)
                  GestureDetector(
                    onTap: () => setState(() => _childLimit += 50),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        context
                            .i18n(TranslationKey.xmlViewerShowMore)
                            .replaceAll(
                              '[remaining]',
                              '${childElements.length - _childLimit}',
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

  String _headerLabel(BuildContext context, int childCount) {
    final attrsNote = element.attributes.isNotEmpty
        ? ' [${element.attributes.length} ${context.i18n(TranslationKey.xmlViewerAttributes)}]'
        : '';
    return '<${element.name.local}>$attrsNote {$childCount}';
  }
}

/// Renders a leaf element: an element with no child elements (may have text or
/// attributes).
class _LeafNode extends StatelessWidget {
  final XmlElement element;

  const _LeafNode({required this.element});

  @override
  Widget build(BuildContext context) {
    final text = element.innerText.trim();
    final attrs = element.attributes;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '<${element.name.local}>: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (text.isNotEmpty)
                Flexible(
                  child: Text(
                    '"$text"',
                    style: const TextStyle(color: Colors.green),
                  ),
                )
              else
                const Text('(empty)', style: TextStyle(color: Colors.grey)),
            ],
          ),
          if (attrs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _AttributesRow(attributes: attrs),
            ),
        ],
      ),
    );
  }
}

/// Renders element attributes as indented key: "value" rows.
class _AttributesRow extends StatelessWidget {
  final Iterable<XmlAttribute> attributes;

  const _AttributesRow({required this.attributes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: attributes.map((attr) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${attr.name.local}: ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              Flexible(
                child: Text(
                  '"${attr.value}"',
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ExpandableHeader extends StatelessWidget {
  final String label;
  final bool isExpanded;
  final VoidCallback onTap;

  const _ExpandableHeader({
    required this.label,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
              size: 20,
            ),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
