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
    if (settings.sessionId.isEmpty) return;

    _client = AgentWebSocketClient(
      host: settings.agentHost,
      sessionId: settings.sessionId,
      authToken: settings.authToken.isEmpty ? null : settings.authToken,
    );

    _client!.onConnectionStatus.listen(_statusController.add);
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
    _traceEvents.clear();
    _traceController.add(const []);
    _client?.onTraceEvent; // ensure stream is warm

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

  void dispose() {
    _client?.dispose();
    _traceController.close();
    _statusController.close();
  }
}
