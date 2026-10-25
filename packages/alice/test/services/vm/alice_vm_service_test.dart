import 'package:alice/alice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AliceVmService registration executes without crashing', () {
    final alice = Alice();
    expect(alice, isNotNull);
  });
}
