import 'package:alice/utils/operating_system.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Returns current storage permission status. Checks permission for iOS
  /// For other platforms it returns true.
  static Future<bool> getPermissionStatus() async {
    if (OperatingSystem.isIOS) {
      return Permission.storage.status.isGranted;
    } else {
      return true;
    }
  }

  /// Requests permissions for storage for iOS. For other platforms it doesn't
  /// make any action and returns true.
  static Future<bool> requestPermission() async {
    if (OperatingSystem.isIOS) {
      return Permission.storage.request().isGranted;
    } else {
      return true;
    }
  }
}
