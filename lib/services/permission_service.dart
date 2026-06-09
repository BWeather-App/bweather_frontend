import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static bool _isRequesting = false;

  static Future<bool> requestLocationPermission() async {
    if (_isRequesting) return false;
    _isRequesting = true;

    try {
      final status = await Permission.locationWhenInUse.request();

      if (status.isGranted || status.isLimited) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }

      return false;
    } finally {
      _isRequesting = false;
    }
  }
}