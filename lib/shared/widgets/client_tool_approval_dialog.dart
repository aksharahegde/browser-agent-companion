import 'package:flutter/material.dart';

import '../../data/models/trace_event.dart';

String clientToolDescription(ToolCallEvent event) {
  return switch (event.toolName) {
    'getClipboardText' => 'Read text from your clipboard',
    'getClipboardImage' => 'Read an image from your clipboard',
    'captureScreenshot' => 'Capture a screenshot of your screen',
    'pickFile' => 'Open a file picker so you can choose a file',
    _ => 'Run local tool "${event.toolName}"',
  };
}

String? clientToolDetail(ToolCallEvent event) {
  if (event.toolName == 'pickFile' && event.input['includeContent'] == true) {
    return 'The selected file contents may be sent to the agent.';
  }
  return null;
}

Future<bool> showClientToolApprovalDialog(
  BuildContext context,
  ToolCallEvent event,
) {
  final detail = clientToolDetail(event);
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Allow local tool?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(clientToolDescription(event)),
          if (detail != null) ...[
            const SizedBox(height: 12),
            Text(
              detail,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Deny'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Allow'),
        ),
      ],
    ),
  ).then((value) => value ?? false);
}
