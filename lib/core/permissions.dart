import 'dart:io';

class PermissionsService {
  static const _screenRecordingSettingsUrls = [
    'x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_ScreenCapture',
    'x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture',
  ];

  Future<bool> hasScreenRecording() async {
    // macOS screen recording is managed via System Settings; no runtime API.
    return false;
  }

  Future<bool> requestScreenRecording() async {
    await openSystemSettings();
    return false;
  }

  Future<void> openSystemSettings() async {
    for (final url in _screenRecordingSettingsUrls) {
      final result = await Process.run('open', [url]);
      if (result.exitCode == 0) return;
    }
  }
}
