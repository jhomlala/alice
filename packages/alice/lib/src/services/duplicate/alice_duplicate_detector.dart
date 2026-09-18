import 'package:alice/src/model/alice_http_call.dart';

class AliceDuplicateDetector {
  static void inspect({
    required AliceHttpCall newCall,
    required List<AliceHttpCall> existingCalls,
    required Duration window,
  }) {
    final cutoff = newCall.createdTime.subtract(window);
    final duplicates = existingCalls
        .where(
          (call) =>
              call.id != newCall.id &&
              call.method == newCall.method &&
              call.endpoint == newCall.endpoint &&
              call.createdTime.isAfter(cutoff),
        )
        .toList();

    if (duplicates.isNotEmpty) {
      newCall.isDuplicate = true;
      for (final d in duplicates) {
        d.isDuplicate = true;
      }
    }
  }
}
