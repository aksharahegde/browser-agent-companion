const sensitiveRunPromptPlaceholder =
    '[Prompt redacted: run included sensitive attachments]';

String redactStoredRunPrompt({
  required String prompt,
  required bool includesSensitiveAttachments,
  int maxLength = 280,
}) {
  if (includesSensitiveAttachments) {
    return sensitiveRunPromptPlaceholder;
  }
  if (prompt.length <= maxLength) return prompt;
  return '${prompt.substring(0, maxLength)}…';
}

bool runIncludesSensitiveAttachments({
  required AgentRunContextFlags flags,
}) {
  return flags.attachedClipboard ||
      flags.attachedScreenshot ||
      flags.promptUsedClipboardTemplate;
}

class AgentRunContextFlags {
  const AgentRunContextFlags({
    required this.attachedClipboard,
    required this.attachedScreenshot,
    required this.promptUsedClipboardTemplate,
  });

  final bool attachedClipboard;
  final bool attachedScreenshot;
  final bool promptUsedClipboardTemplate;
}
