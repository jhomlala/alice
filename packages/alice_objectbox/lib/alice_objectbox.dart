import 'package:alice_objectbox/model/cached_alice_http_call.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'objectbox.g.dart';

/// Provides access to the ObjectBox Store throughout the app.
///
/// Create this in the apps main function.
class AliceObjectBox {
  late final Store _store;

  late final Box<CachedAliceHttpCall> httpCalls;

  AliceObjectBox._create(this._store) {
    httpCalls = Box<CachedAliceHttpCall>(_store);
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<AliceObjectBox> create([Store? store]) async {
    final String storeDirectoryPath = path.join(
      (await getApplicationDocumentsDirectory()).path,
      Store.defaultDirectoryPath,
      "alice",
    );

    store ??= Store.isOpen(storeDirectoryPath)
        ? Store.attach(getObjectBoxModel(), storeDirectoryPath)
        : await openStore(directory: storeDirectoryPath);

    return AliceObjectBox._create(store);
  }
}
