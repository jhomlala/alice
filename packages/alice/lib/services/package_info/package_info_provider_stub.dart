import 'package_info_wrapper.dart';

class PackageInfoProvider {
  static Future<PackageInfoWrapper> getPackageInfo() async {
    return PackageInfoWrapper(
      appName: '',
      packageName: '',
      version: '',
      buildNumber: '',
    );
  }
}
