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
        if (picked == null) return {'error': 'No file selected'};
        return {
          'path': picked.path,
          'name': picked.name,
          'mime': picked.mime,
          if (picked.base64 != null) 'base64': picked.base64,
        };
      case 'readFile':
        final path = event.input['path'] as String?;
        if (path == null) return {'error': 'path is required'};
        final file = await _fileService.readFile(path);
        if (file == null) return {'error': 'File not found'};
        return {'content': file.content, 'mime': file.mime};
      default:
        return {'error': 'Unsupported tool: ${event.toolName}'};
    }
  }
}
