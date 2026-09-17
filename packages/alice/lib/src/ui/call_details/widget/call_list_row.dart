import 'package:material_ui/material_ui.dart';

/// Widget which displays formatted text row. It allows to select the text.
class CallListRow extends StatelessWidget {
  final String name;
  final String? value;

  const CallListRow({required this.name, this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Padding(padding: EdgeInsets.only(left: 5)),
        Flexible(
          child: value != null ? SelectableText(value!) : const SizedBox(),
        ),
        const Padding(padding: EdgeInsets.only(bottom: 18)),
      ],
    );
  }
}
