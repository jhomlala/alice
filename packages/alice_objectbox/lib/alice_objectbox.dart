import 'package:alice/alice.dart';
import 'package:alice_objectbox/alice_store.dart';
import 'package:alice_objectbox/core/alice_core_objectbox.dart';

class AliceObjectBox extends Alice {
  AliceObjectBox({
    required AliceStore store,
    required super.showNotification,
    required super.showInspectorOnShake,
    required super.notificationIcon,
    required super.maxCallsCount,
    super.directionality,
    super.showShareButton,
  }) : _store = store;

  final AliceStore _store;

  @override
  AliceCoreObjectBox buildAliceCore() => AliceCoreObjectBox(
        getNavigatorKey(),
        store: _store,
        showNotification: showNotification,
        showInspectorOnShake: showInspectorOnShake,
        notificationIcon: notificationIcon,
        maxCallsCount: maxCallsCount,
        directionality: directionality,
        showShareButton: showShareButton,
      );
}
