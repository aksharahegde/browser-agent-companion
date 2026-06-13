import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:screen_capturer/screen_capturer.dart';

import '../../core/logging.dart';

class ScreenshotService {
  Future<({String base64, int width, int height})?> captureScreen() async {
    File? tempFile;
    try {
      final tempDir = await getTemporaryDirectory();
      final imagePath = p.join(
        tempDir.path,
        'cua_screenshot_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      tempFile = File(imagePath);

      final captured = await screenCapturer.capture(
        mode: CaptureMode.screen,
        imagePath: imagePath,
        copyToClipboard: false,
        silent: true,
      );
      if (captured == null || captured.imagePath == null) return null;

      final file = File(captured.imagePath!);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      return (
        base64: base64Encode(bytes),
        width: 0,
        height: 0,
      );
    } catch (error, stackTrace) {
      logError('Screenshot failed', error: error, stackTrace: stackTrace);
      return null;
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }
  }
}
