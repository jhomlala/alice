import 'package:alice/src/model/alice_http_call.dart';
import 'package:alice/src/services/duplicate/alice_duplicate_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AliceDuplicateDetector', () {
    test('should flag duplicate calls', () {
      final window = const Duration(milliseconds: 500);
      final existingCall1 = AliceHttpCall(1)
        ..method = 'GET'
        ..endpoint = '/api/data';

      // Ensure some small time has passed just in case, though they are sequential.

      final existingCall2 = AliceHttpCall(2)
        ..method = 'POST'
        ..endpoint = '/api/data';

      final newCall = AliceHttpCall(3)
        ..method = 'GET'
        ..endpoint = '/api/data';

      AliceDuplicateDetector.inspect(
        newCall: newCall,
        existingCalls: [existingCall1, existingCall2],
        window: window,
      );

      expect(newCall.isDuplicate, isTrue);
      expect(existingCall1.isDuplicate, isTrue);
      expect(existingCall2.isDuplicate, isFalse);
    });

    test('should not flag duplicate calls if outside window', () async {
      final window = const Duration(milliseconds: 100);
      final existingCall = AliceHttpCall(1)
        ..method = 'GET'
        ..endpoint = '/api/data';

      await Future.delayed(const Duration(milliseconds: 150));

      final newCall = AliceHttpCall(2)
        ..method = 'GET'
        ..endpoint = '/api/data';

      AliceDuplicateDetector.inspect(
        newCall: newCall,
        existingCalls: [existingCall],
        window: window,
      );

      expect(newCall.isDuplicate, isFalse);
      expect(existingCall.isDuplicate, isFalse);
    });

    test(
      'should not flag duplicate calls with different endpoints or methods',
      () {
        final window = const Duration(milliseconds: 500);
        final existingCall1 = AliceHttpCall(1)
          ..method = 'GET'
          ..endpoint = '/api/data1';

        final existingCall2 = AliceHttpCall(2)
          ..method = 'POST'
          ..endpoint = '/api/data2';

        final newCall = AliceHttpCall(3)
          ..method = 'GET'
          ..endpoint = '/api/data2';

        AliceDuplicateDetector.inspect(
          newCall: newCall,
          existingCalls: [existingCall1, existingCall2],
          window: window,
        );

        expect(newCall.isDuplicate, isFalse);
        expect(existingCall1.isDuplicate, isFalse);
        expect(existingCall2.isDuplicate, isFalse);
      },
    );
  });
}
