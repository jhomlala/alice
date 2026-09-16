import 'package_info_wrapper.dart';

Future<PackageInfoWrapper> getPackageInfo() async {
  return PackageInfoWrapper(
    appName: '',
    packageName: '',
    version: '',
    buildNumber: '',
  );
}
