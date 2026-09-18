class AliceTagService {
  String? _activeTag;
  int? _remaining;

  void tag(String tag, {int? maxCalls}) {
    _activeTag = tag;
    _remaining = maxCalls;
  }

  void clearTag() {
    _activeTag = null;
    _remaining = null;
  }

  String? consumeTag() {
    final currentTag = _activeTag;
    if (_remaining != null) {
      _remaining = _remaining! - 1;
      if (_remaining! <= 0) {
        clearTag();
      }
    }
    return currentTag;
  }
}
