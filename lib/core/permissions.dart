import 'package:permission_handler/permission_handler.dart' show openAppSettings;

class PermissionsService {
  Future<bool> hasScreenRecording() async {
    // macOS screen recording is managed via System Settings; no runtime API.
    return false;
  }

  Future<bool> requestScreenRecording() async {
    await openAppSettings();
    return false;
  }

  Future<void> openSystemSettings() async {
    await openAppSettings();
  }
}
