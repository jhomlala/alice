import 'package:flutter/material.dart';

/// Widget which displays expandable formatted row of text.
class AliceCallExpandableListRow extends StatelessWidget {
  final String name;
  final String value;

  const AliceCallExpandableListRow({
    required this.name,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(value, maxLines: 2, overflow: TextOverflow.ellipsis),
      controlAffinity: ListTileControlAffinity.trailing,
      tilePadding: const EdgeInsets.all(0),
      children: [SelectableText(value)],
    );
  }
}
