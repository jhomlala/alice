import 'package:alice/src/model/alice_http_call.dart';

class AliceDuplicateDetector {
  static void inspect(AliceHttpCall newCall, List<AliceHttpCall> existingCalls, Duration window) {
    final cutoff = newCall.createdTime.subtract(window);
    final duplicates = existingCalls.where((c) =>
      c.id != newCall.id &&
      c.method == newCall.method &&
      c.endpoint == newCall.endpoint &&
      c.createdTime.isAfter(cutoff),
    ).toList();
    
    if (duplicates.isNotEmpty) {
      newCall.isDuplicate = true;
      for (final d in duplicates) {
        d.isDuplicate = true;
      }
    }
  }
}
