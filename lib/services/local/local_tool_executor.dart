import '../../core/config.dart';
import '../../data/models/trace_event.dart';
import 'clipboard_service.dart';
import 'file_service.dart';
import 'screenshot_service.dart';

class LocalToolExecutor {
  LocalToolExecutor({
    required ClipboardService clipboardService,
    required ScreenshotService screenshotService,
    required FileService fileService,
  })  : _clipboardService = clipboardService,
        _screenshotService = screenshotService,
        _fileService = fileService;

  final ClipboardService _clipboardService;
  final ScreenshotService _screenshotService;
  final FileService _fileService;

  Future<Map<String, dynamic>> execute(ToolCallEvent event) async {
    switch (event.toolName) {
      case 'getClipboardText':
        final text = await _clipboardService.readText();
        return {'text': text ?? ''};
      case 'getClipboardImage':
        final image = await _clipboardService.readImage();
        if (image == null) return {'error': 'No image on clipboard'};
        return {'base64': image.base64, 'mime': image.mime};
      case 'captureScreenshot':
        final shot = await _screenshotService.captureScreen();
        if (shot == null) return {'error': 'Screenshot failed'};
        return {
          'base64': shot.base64,
          'width': shot.width,
          'height': shot.height,
        };
      case 'pickFile':
        final picked = await _fileService.pickFile(
          includeContent: event.input['includeContent'] == true,
        );
        if (picked == null) {
          return {
            'error': event.input['includeContent'] == true
                ? 'No file selected or file exceeds ${AppConfig.maxFileReadBytes ~/ (1024 * 1024)} MB limit'
                : 'No file selected',
          };
        }
        return {
          'path': picked.path,
          'name': picked.name,
          'mime': picked.mime,
          if (picked.base64 != null) 'base64': picked.base64,
        };
      case 'readFile':
        return {
          'error':
              'readFile is disabled; the agent must use pickFile so you choose the file',
        };
      default:
        return {'error': 'Unsupported tool: ${event.toolName}'};
    }
  }
}
