import 'package:alice/src/services/tag/alice_tag_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AliceTagService', () {
    late AliceTagService tagService;

    setUp(() {
      tagService = AliceTagService();
    });

    test('should tag calls indefinitely when maxCalls is not provided', () {
      tagService.tag(tag: 'test-flow');

      expect(tagService.consumeTag(), 'test-flow');
      expect(tagService.consumeTag(), 'test-flow');
      expect(tagService.consumeTag(), 'test-flow');
    });

    test('should stop tagging after maxCalls is reached', () {
      tagService.tag(tag: 'test-flow', maxCalls: 2);

      expect(tagService.consumeTag(), 'test-flow');
      expect(tagService.consumeTag(), 'test-flow');
      expect(tagService.consumeTag(), isNull);
    });

    test('should clear active tag manually', () {
      tagService.tag(tag: 'test-flow');
      expect(tagService.consumeTag(), 'test-flow');

      tagService.clearTag();
      expect(tagService.consumeTag(), isNull);
    });

    test('should overwrite existing tag', () {
      tagService.tag(tag: 'test-flow-1', maxCalls: 5);
      tagService.tag(tag: 'test-flow-2', maxCalls: 1);

      expect(tagService.consumeTag(), 'test-flow-2');
      expect(tagService.consumeTag(), isNull);
    });
  });
}
