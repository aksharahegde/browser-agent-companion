import 'dart:convert';
import 'dart:io';

import 'package:screen_capturer/screen_capturer.dart';

import '../../core/logging.dart';

class ScreenshotService {
  Future<({String base64, int width, int height})?> captureScreen() async {
    try {
      final captured = await screenCapturer.capture(
        mode: CaptureMode.screen,
        imagePath: null,
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
    }
  }
}
