import 'dart:async';

import '../../data/models/app_settings.dart';
import '../../data/models/trace_event.dart';
import 'agent_websocket_client.dart';

class AgentSessionService {
  AgentSessionService();

  AgentWebSocketClient? _client;
  final _traceEvents = <TraceEvent>[];
  final _traceController = StreamController<List<TraceEvent>>.broadcast();
  final _statusController =
      StreamController<ConnectionStatus>.broadcast();

  Stream<List<TraceEvent>> get traceEvents => _traceController.stream;
  Stream<ConnectionStatus> get connectionStatus => _statusController.stream;
  ConnectionStatus get status =>
      _client?.status ?? ConnectionStatus.disconnected;
  List<TraceEvent> get currentTrace => List.unmodifiable(_traceEvents);

  Future<void> configure(AppSettings settings) async {
    await disconnect();
    if (settings.activeSessionId.isEmpty) return;

    _traceEvents.clear();
    _traceController.add(const []);

    _client = AgentWebSocketClient(
      host: settings.agentHost,
      sessionId: settings.activeSessionId,
      authToken: settings.authToken.isEmpty ? null : settings.authToken,
    );

    _client!.onConnectionStatus.listen(_statusController.add);
    _client!.onStateUpdate.listen(_hydrateTraceFromState);
    _client!.onTraceEvent.listen((event) {
      _traceEvents.add(event);
      _traceController.add(List.unmodifiable(_traceEvents));
    });
    _client!.onToolCall.listen(_handleToolCall);

    await _client!.connect();
  }

  Future<void> disconnect() async {
    await _client?.disconnect();
    _client?.dispose();
    _client = null;
  }

  Future<void> runWorkflow(
    String prompt,
    AgentRunContext context, {
    void Function(Object error)? onError,
  }) async {
    final client = _client;
    if (client == null || client.status != ConnectionStatus.connected) {
      throw StateError('Agent is not connected');
    }

    try {
      await client.call('sendMessage', [
        prompt,
        context.toJson(),
      ]);
    } catch (error) {
      onError?.call(error);
      rethrow;
    }
  }

  Future<void> submitToolResult(
    String toolCallId,
    Map<String, dynamic> output,
  ) async {
    final client = _client;
    if (client == null) return;
    await client.call('addToolOutput', [
      {'toolCallId': toolCallId, 'output': output},
    ]);
  }

  Future<void> cancelRun() async {
    final client = _client;
    if (client == null) return;
    try {
      await client.call('cancel', []);
    } catch (_) {}
  }

  void clearTrace() {
    _traceEvents.clear();
    _traceController.add(const []);
  }

  Future<void> Function(ToolCallEvent event)? onToolCallRequested;

  Future<void> _handleToolCall(ToolCallEvent event) async {
    final handler = onToolCallRequested;
    if (handler == null) return;
    await handler(event);
  }

  void _hydrateTraceFromState(Map<String, dynamic> state) {
    _traceEvents
      ..clear()
      ..addAll(buildTraceFromState(state));
    _traceController.add(List.unmodifiable(_traceEvents));
  }

  static List<TraceEvent> buildTraceFromState(Map<String, dynamic> state) {
    final events = <TraceEvent>[];
    var seq = 0;

    TraceEvent add(TraceEventType type, String message) {
      return TraceEvent(
        id: 'state-${seq++}',
        type: type,
        message: message,
        timestamp: DateTime.now(),
      );
    }

    final status = state['status'] as String?;
    if (status != null) {
      events.add(add(TraceEventType.status, 'Agent status: $status'));
    }

    final messages = state['messages'];
    if (messages is List) {
      for (final message in messages) {
        if (message is! Map) continue;
        final role = message['role'] as String? ?? 'agent';
        final text = _messageText(message['content']);
        if (text.isEmpty) continue;
        events.add(
          add(
            role == 'user'
                ? TraceEventType.userPrompt
                : TraceEventType.agentResponse,
            text,
          ),
        );
      }
    }

    final activeTools = state['activeToolCalls'];
    if (activeTools is List) {
      for (final tool in activeTools) {
        if (tool is Map) {
          events.add(
            add(
              TraceEventType.serverToolCall,
              'Server tool: ${tool['name'] ?? tool['toolName'] ?? 'unknown'}',
            ),
          );
        }
      }
    }

    return events;
  }

  static String _messageText(Object? content) {
    if (content is String) return content;
    if (content is List) {
      return content
          .whereType<Map>()
          .map((part) => part['text'])
          .whereType<String>()
          .join('\n');
    }
    return content?.toString() ?? '';
  }

  void dispose() {
    _client?.dispose();
    _traceController.close();
    _statusController.close();
  }
}
