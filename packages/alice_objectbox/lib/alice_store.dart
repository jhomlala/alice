import 'dart:io' show Directory;

import 'package:alice_objectbox/model/cached_alice_http_call.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'objectbox.g.dart';

/// Provides access to the ObjectBox Store throughout the app.
///
/// Create this in the apps main function.
class AliceStore {
  AliceStore._create(this._store) {
    httpCalls = Box<CachedAliceHttpCall>(_store);
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<AliceStore> create([Store? store]) async {
    final String storeDirectoryPath = path.join(
      (await getApplicationDocumentsDirectory()).path,
      Store.defaultDirectoryPath,
      "alice",
    );

    await Directory(storeDirectoryPath).create(recursive: true);

    store ??= Store.isOpen(storeDirectoryPath)
        ? Store.attach(getObjectBoxModel(), storeDirectoryPath)
        : await openStore(directory: storeDirectoryPath);

    return AliceStore._create(store);
  }

  late final Store _store;

  /// Boxes
  late final Box<CachedAliceHttpCall> httpCalls;
}
