import 'package:flutter/material.dart';

/// Line of texts used in stats.
class AliceStatsRow extends StatelessWidget {
  const AliceStatsRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const Padding(padding: EdgeInsets.only(left: 10)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
