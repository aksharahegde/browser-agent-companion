import 'dart:async';

import '../../data/models/app_settings.dart';
import '../../data/models/trace_event.dart';
import 'agent_backend_probe.dart';
import 'agent_host_validator.dart';
import 'agent_http_run_client.dart';
import 'agent_websocket_client.dart';

enum _AgentBackend { none, httpRun, websocket }

class AgentSessionService {
  AgentSessionService();

  AgentWebSocketClient? _wsClient;
  AgentHttpRunClient? _httpClient;
  _AgentBackend _backend = _AgentBackend.none;
  String? _configuredHost;
  String? _configuredSessionId;
  String? _configuredAuthToken;

  final _traceEvents = <TraceEvent>[];
  final _traceController = StreamController<List<TraceEvent>>.broadcast();
  final _statusController =
      StreamController<ConnectionStatus>.broadcast();
  final _subscriptions = <StreamSubscription<dynamic>>[];

  Stream<List<TraceEvent>> get traceEvents => _traceController.stream;
  Stream<ConnectionStatus> get connectionStatus => _statusController.stream;
  ConnectionStatus get status {
    return _httpClient?.status ??
        _wsClient?.status ??
        ConnectionStatus.disconnected;
  }

  List<TraceEvent> get currentTrace => List.unmodifiable(_traceEvents);

  Future<void> configure(AppSettings settings) async {
    await disconnect();

    _traceEvents.clear();
    _emitTrace(const []);

    try {
      _configuredHost = parseAgentHost(settings.agentHost);
    } on AgentHostValidationException catch (error) {
      _emitTrace([
        TraceEvent(
          id: 'host-validation',
          type: TraceEventType.error,
          message: error.message,
          timestamp: DateTime.now(),
        ),
      ]);
      _emitStatus(ConnectionStatus.error);
      return;
    }

    _configuredSessionId = settings.activeSessionId;
    _configuredAuthToken =
        settings.authToken.isEmpty ? null : settings.authToken;

    if (settings.activeSessionId.isNotEmpty) {
      await _configureWebSocket(
        host: _configuredHost!,
        sessionId: settings.activeSessionId,
        authToken: _configuredAuthToken,
      );
      return;
    }

    if (_configuredAuthToken == null) {
      _emitTrace([
        TraceEvent(
          id: 'http-auth-required',
          type: TraceEventType.error,
          message: 'HTTP /run backend requires an auth token',
          timestamp: DateTime.now(),
        ),
      ]);
      _emitStatus(ConnectionStatus.error);
      return;
    }

    final useHttpRun = await probeHttpRunBackend(
      _configuredHost!,
      authToken: _configuredAuthToken,
    );
    if (!useHttpRun) {
      _emitStatus(ConnectionStatus.error);
      return;
    }

    await _configureHttpRun(
      host: _configuredHost!,
      authToken: _configuredAuthToken!,
    );
  }

  Future<void> _configureWebSocket({
    required String host,
    required String sessionId,
    String? authToken,
  }) async {
    _backend = _AgentBackend.websocket;
    _wsClient = AgentWebSocketClient(
      host: host,
      sessionId: sessionId,
      authToken: authToken,
    );

    _subscriptions.add(_wsClient!.onConnectionStatus.listen(_emitStatus));
    _subscriptions.add(_wsClient!.onStateUpdate.listen(_hydrateTraceFromState));
    _subscriptions.add(
      _wsClient!.onTraceEvent.listen((event) {
        _traceEvents.add(event);
        _emitTrace(List.unmodifiable(_traceEvents));
      }),
    );
    _subscriptions.add(_wsClient!.onToolCall.listen(_handleToolCall));

    await _wsClient!.connect();
  }

  Future<void> _configureHttpRun({
    required String host,
    required String authToken,
  }) async {
    _backend = _AgentBackend.httpRun;
    _httpClient = AgentHttpRunClient(host: host, authToken: authToken);
    _subscriptions.add(_httpClient!.onConnectionStatus.listen(_emitStatus));
    _subscriptions.add(
      _httpClient!.onTraceEvent.listen((event) {
        _traceEvents.add(event);
        _emitTrace(List.unmodifiable(_traceEvents));
      }),
    );
    await _httpClient!.connect();
  }

  Future<void> disconnect() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();

    await _httpClient?.disconnect();
    _httpClient?.dispose();
    _httpClient = null;

    await _wsClient?.disconnect();
    _wsClient?.dispose();
    _wsClient = null;

    _backend = _AgentBackend.none;
    _configuredHost = null;
    _configuredSessionId = null;
    _configuredAuthToken = null;
  }

  Future<void> runWorkflow(
    String prompt,
    AgentRunContext context, {
    void Function(Object error)? onError,
  }) async {
    if (status != ConnectionStatus.connected) {
      throw StateError('Agent is not connected');
    }

    try {
      switch (_backend) {
        case _AgentBackend.httpRun:
          await _httpClient!.run(prompt, context);
        case _AgentBackend.websocket:
          await _wsClient!.call('sendMessage', [
            prompt,
            context.toJson(),
          ]);
        case _AgentBackend.none:
          throw StateError('Agent is not connected');
      }
    } catch (error) {
      onError?.call(error);
      rethrow;
    }
  }

  Future<void> ensureConnected(
    AppSettings settings, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final needsConfigure = _backend == _AgentBackend.none ||
        _configuredHost != settings.agentHost ||
        _configuredSessionId != settings.activeSessionId ||
        _configuredAuthToken !=
            (settings.authToken.isEmpty ? null : settings.authToken);

    if (needsConfigure) {
      await configure(settings);
    } else if (status != ConnectionStatus.connected &&
        status != ConnectionStatus.connecting &&
        status != ConnectionStatus.reconnecting) {
      if (_httpClient != null) {
        await _httpClient!.connect();
      } else {
        await _wsClient!.connect();
      }
    }

    if (_backend == _AgentBackend.websocket &&
        settings.activeSessionId.isEmpty) {
      throw StateError('No active session configured');
    }

    if (_backend == _AgentBackend.none) {
      throw StateError('Agent is not connected');
    }

    if (status == ConnectionStatus.connected) return;

    try {
      await connectionStatus
          .firstWhere((status) => status == ConnectionStatus.connected)
          .timeout(timeout);
    } on TimeoutException {
      throw StateError('Agent is not connected');
    }
  }

  Future<void> submitToolResult(
    String toolCallId,
    Map<String, dynamic> output,
  ) async {
    if (_backend != _AgentBackend.websocket) return;
    final client = _wsClient;
    if (client == null) return;
    await client.call('addToolOutput', [
      {'toolCallId': toolCallId, 'output': output},
    ]);
  }

  Future<void> cancelRun() async {
    if (_httpClient != null) {
      await _httpClient!.cancelRun();
      return;
    }
    final client = _wsClient;
    if (client == null) return;
    try {
      await client.call('cancel', []);
    } catch (_) {}
  }

  void clearTrace() {
    _traceEvents.clear();
    _emitTrace(const []);
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
    _emitTrace(List.unmodifiable(_traceEvents));
  }

  void _emitStatus(ConnectionStatus status) {
    if (_statusController.isClosed) return;
    _statusController.add(status);
  }

  void _emitTrace(List<TraceEvent> events) {
    if (_traceController.isClosed) return;
    _traceController.add(events);
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
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _httpClient?.dispose();
    _wsClient?.dispose();
    _traceController.close();
    _statusController.close();
  }
}
