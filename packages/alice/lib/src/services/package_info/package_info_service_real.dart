import 'package:package_info_plus/package_info_plus.dart';

import 'package_info_wrapper.dart';

class PackageInfoService {
  static Future<PackageInfoWrapper> getPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return PackageInfoWrapper(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );
  }
}
