import 'package:alice/utils/alice_constants.dart';
import 'package:flutter/material.dart';

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
              color: AliceConstants.orange,
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
