import 'dart:io' show Directory;

import 'package:alice/core/alice_store.dart';
import 'package:alice_objectbox/model/cached_alice_http_call.dart';
import 'package:alice_objectbox/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Provides access to the ObjectBox Store throughout the app.
///
/// Create this in the apps main function.
class AliceObjectBoxStore implements AliceStore {
  AliceObjectBoxStore._create(
    this._store, {
    bool persistent = true,
  }) {
    /// Initialize all the boxes here
    httpCalls = Box<CachedAliceHttpCall>(_store);

    if (!persistent) {
      clear();
    }
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<AliceObjectBoxStore> create({
    Store? store,
    bool persistent = true,
  }) async {
    final String storeDirectoryPath = path.join(
      (await getApplicationDocumentsDirectory()).path,
      Store.defaultDirectoryPath,
      "alice",
    );

    final Directory storeDirectory = Directory(storeDirectoryPath);
    if (!await storeDirectory.exists()) {
      await storeDirectory.create(recursive: true);
    }

    store ??= Store.isOpen(storeDirectoryPath)
        ? Store.attach(getObjectBoxModel(), storeDirectoryPath)
        : await openStore(directory: storeDirectoryPath);

    return AliceObjectBoxStore._create(store, persistent: persistent);
  }

  late final Store _store;

  /// Boxes
  late final Box<CachedAliceHttpCall> httpCalls;

  late final Map<Type, Box> _boxes = {
    CachedAliceHttpCall: httpCalls,
  };

  /// This will remove all the items from all the boxes
  @override
  void clear() {
    for (final Box box in _boxes.values) {
      box.removeAll();
    }
  }
}
