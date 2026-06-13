enum ConnectionStatus { disconnected, connecting, connected, reconnecting, error }

enum RunStatus { pending, running, completed, failed, cancelled }

enum TraceEventType {
  userPrompt,
  agentThinking,
  serverToolCall,
  clientToolCall,
  clientToolResult,
  agentResponse,
  error,
  status,
}

class TraceEvent {
  const TraceEvent({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    this.metadata = const {},
  });

  final String id;
  final TraceEventType type;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  TraceEvent copyWith({
    String? message,
    Map<String, dynamic>? metadata,
  }) {
    return TraceEvent(
      id: id,
      type: type,
      message: message ?? this.message,
      timestamp: timestamp,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ToolCallEvent {
  const ToolCallEvent({
    required this.toolCallId,
    required this.toolName,
    required this.input,
  });

  final String toolCallId;
  final String toolName;
  final Map<String, dynamic> input;
}

class AgentRunContext {
  const AgentRunContext({
    this.clipboardText,
    this.screenshotBase64,
    this.filePath,
    this.fileContent,
    this.extra = const {},
  });

  final String? clipboardText;
  final String? screenshotBase64;
  final String? filePath;
  final String? fileContent;
  final Map<String, dynamic> extra;

  Map<String, dynamic> toJson() => {
        if (clipboardText != null) 'clipboardText': clipboardText,
        if (screenshotBase64 != null) 'screenshotBase64': screenshotBase64,
        if (filePath != null) 'filePath': filePath,
        if (fileContent != null) 'fileContent': fileContent,
        ...extra,
      };
}
