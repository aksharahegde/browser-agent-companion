import 'package:cua_companion/data/models/trace_event.dart';
import 'package:cua_companion/services/local/clipboard_service.dart';
import 'package:cua_companion/services/local/file_service.dart';
import 'package:cua_companion/services/local/local_tool_executor.dart';
import 'package:cua_companion/services/local/screenshot_service.dart';
import 'package:cua_companion/shared/widgets/client_tool_approval_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalToolExecutor', () {
    late LocalToolExecutor executor;

    setUp(() {
      executor = LocalToolExecutor(
        clipboardService: ClipboardService(),
        screenshotService: ScreenshotService(),
        fileService: FileService(),
      );
    });

    test('readFile is disabled', () async {
      final result = await executor.execute(
        const ToolCallEvent(
          toolCallId: '1',
          toolName: 'readFile',
          input: {'path': '/etc/passwd'},
        ),
      );

      expect(result['error'], contains('readFile is disabled'));
    });
  });

  group('clientToolDescription', () {
    test('describes known tools', () {
      expect(
        clientToolDescription(
          const ToolCallEvent(
            toolCallId: '1',
            toolName: 'captureScreenshot',
            input: {},
          ),
        ),
        contains('screenshot'),
      );
    });
  });
}
