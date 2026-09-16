export 'package_info_provider_stub.dart'
    if (dart.library.io) 'package_info_provider_real.dart'
    if (dart.library.html) 'package_info_provider_real.dart';
