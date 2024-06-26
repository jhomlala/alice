import 'package:alice/utils/alice_theme.dart';
import 'package:flutter/material.dart';

/// Widget which renders empty text for calls list.
class AliceEmptyLogsWidget extends StatelessWidget {
  const AliceEmptyLogsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AliceTheme.orange,
            ),
            SizedBox(height: 6),
            Text(
              'There are no logs to show',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
