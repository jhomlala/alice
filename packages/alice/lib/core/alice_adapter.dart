import 'package:alice/core/alice_core.dart';

/// Adapter mixin which is used in http client adapters.
mixin AliceAdapter {
  late final AliceCore aliceCore;

  void injectCore(AliceCore aliceCore) => this.aliceCore = aliceCore;
}
