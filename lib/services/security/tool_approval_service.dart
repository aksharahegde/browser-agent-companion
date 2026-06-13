import '../../data/models/trace_event.dart';
import '../../shared/widgets/client_tool_approval_dialog.dart';
import '../../shared/app_navigator.dart';

typedef ShowWindowCallback = Future<void> Function();

class ToolApprovalService {
  ToolApprovalService({required ShowWindowCallback showWindow})
      : _showWindow = showWindow;

  final ShowWindowCallback _showWindow;

  Future<bool> requestApproval(ToolCallEvent event) async {
    await _showWindow();

    final context = appNavigatorKey.currentContext;
    if (context == null || !context.mounted) return false;

    return showClientToolApprovalDialog(context, event);
  }
}
