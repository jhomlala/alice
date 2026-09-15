import 'package:material_ui/material_ui.dart';

class AliceJsonViewer extends StatelessWidget {
  final dynamic json;

  const AliceJsonViewer({required this.json, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _JsonNode(
          content: json,
          name: null,
        ),
      ],
    );
  }
}

class _JsonNode extends StatefulWidget {
  final dynamic content;
  final String? name;

  const _JsonNode({
    required this.content,
    this.name,
  });

  @override
  State<_JsonNode> createState() => _JsonNodeState();
}

class _JsonNodeState extends State<_JsonNode> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    if (content is Map) {
      return _buildMapNode(content);
    } else if (content is List) {
      return _buildListNode(content);
    } else {
      return _buildLeafNode(content);
    }
  }

  Widget _buildMapNode(Map map) {
    if (map.isEmpty) {
      return _buildLeafNode('{}');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NodeHeader(
          name: widget.name,
          info: '{${map.length}}',
          expanded: _expanded,
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final key in map.keys)
                  _JsonNode(
                    name: key.toString(),
                    content: map[key],
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildListNode(List list) {
    if (list.isEmpty) {
      return _buildLeafNode('[]');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NodeHeader(
          name: widget.name,
          info: '[${list.length}]',
          expanded: _expanded,
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < list.length; i++)
                  _JsonNode(
                    name: i.toString(),
                    content: list[i],
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLeafNode(dynamic value) {
    String valueText = value.toString();
    Color valueColor = Colors.grey;

    if (value is String) {
      valueText = '"$value"';
      valueColor = Colors.green;
    } else if (value is num) {
      valueColor = Colors.orange;
    } else if (value is bool) {
      valueColor = Colors.blue;
    } else if (value == null) {
      valueText = 'null';
      valueColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.name != null)
            Text(
              '${widget.name}: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          Flexible(
            child: Text(
              valueText,
              style: TextStyle(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _NodeHeader extends StatelessWidget {
  final String? name;
  final String info;
  final bool expanded;
  final VoidCallback onTap;

  const _NodeHeader({
    required this.name,
    required this.info,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              expanded ? Icons.arrow_drop_down : Icons.arrow_right,
              size: 20,
              color: Colors.grey,
            ),
            if (name != null)
              Text(
                '$name: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            Text(
              info,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
