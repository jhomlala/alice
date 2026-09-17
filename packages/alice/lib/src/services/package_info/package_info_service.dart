export 'package_info_service_stub.dart'
    if (dart.library.io) 'package_info_service_real.dart'
    if (dart.library.html) 'package_info_service_real.dart';
