import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/config.dart';
import '../../core/logging.dart';
import '../../data/models/trace_event.dart';

class AgentWebSocketClient {
  AgentWebSocketClient({
    required this.host,
    required this.sessionId,
    this.authToken,
  });

  final String host;
  final String sessionId;
  final String? authToken;

  WebSocketChannel? _channel;
  final _pendingRpc = <String, Completer<dynamic>>{};
  final _stateController = StreamController<Map<String, dynamic>>.broadcast();
  final _toolCallController = StreamController<ToolCallEvent>.broadcast();
  final _connectionController =
      StreamController<ConnectionStatus>.broadcast();
  final _traceController = StreamController<TraceEvent>.broadcast();
  final _uuid = const Uuid();

  ConnectionStatus _status = ConnectionStatus.disconnected;
  Map<String, dynamic> _latestState = {};
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  bool _intentionalDisconnect = false;

  Stream<Map<String, dynamic>> get onStateUpdate => _stateController.stream;
  Stream<ToolCallEvent> get onToolCall => _toolCallController.stream;
  Stream<ConnectionStatus> get onConnectionStatus =>
      _connectionController.stream;
  Stream<TraceEvent> get onTraceEvent => _traceController.stream;
  ConnectionStatus get status => _status;
  Map<String, dynamic> get latestState => Map.unmodifiable(_latestState);

  Future<void> connect() async {
    _intentionalDisconnect = false;
    await _openSocket();
  }

  Future<void> disconnect() async {
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _setStatus(ConnectionStatus.disconnected);
  }

  Future<dynamic> call(
    String method,
    List<dynamic> args, {
    Duration timeout = AppConfig.rpcTimeout,
  }) async {
    final id = _uuid.v4();
    final completer = Completer<dynamic>();
    _pendingRpc[id] = completer;

    _send({
      'type': 'rpc',
      'id': id,
      'method': method,
      'args': args,
    });

    return completer.future.timeout(
      timeout,
      onTimeout: () {
        _pendingRpc.remove(id);
        throw TimeoutException('RPC $method timed out');
      },
    );
  }

  void setState(Map<String, dynamic> state) {
    _send({'type': 'cf_agent_state', 'state': state});
  }

  Future<void> _openSocket() async {
    if (_status == ConnectionStatus.connecting) return;
    _setStatus(
      _reconnectAttempt > 0
          ? ConnectionStatus.reconnecting
          : ConnectionStatus.connecting,
    );

    try {
      final uri = _buildUri();
      logInfo('Connecting to $uri');
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;
      _reconnectAttempt = 0;
      _setStatus(ConnectionStatus.connected);
      _emitTrace(TraceEventType.status, 'Connected to agent');

      _channel!.stream.listen(
        _handleMessage,
        onError: (Object error) {
          logError('WebSocket error', error: error);
          _setStatus(ConnectionStatus.error);
          _scheduleReconnect();
        },
        onDone: () {
          if (!_intentionalDisconnect) {
            _setStatus(ConnectionStatus.reconnecting);
            _scheduleReconnect();
          }
        },
        cancelOnError: true,
      );
    } catch (error, stackTrace) {
      logError('Failed to connect', error: error, stackTrace: stackTrace);
      _setStatus(ConnectionStatus.error);
      _scheduleReconnect();
    }
  }

  Uri _buildUri() {
    final base = host.endsWith('/') ? host.substring(0, host.length - 1) : host;
    final wsBase = base
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    final query = <String, String>{};
    if (authToken != null && authToken!.isNotEmpty) {
      query['token'] = authToken!;
    }
    return Uri.parse(
      '$wsBase/agents/${AppConfig.agentClassName}/$sessionId',
    ).replace(queryParameters: query.isEmpty ? null : query);
  }

  void _handleMessage(dynamic raw) {
    Map<String, dynamic> message;
    try {
      message = jsonDecode(raw as String) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final type = message['type'] as String?;
    if (type == 'rpc') {
      _handleRpc(message);
      return;
    }

    if (type == 'cf_agent_state' || message.containsKey('state')) {
      final state = (message['state'] as Map?)?.cast<String, dynamic>() ??
          message.cast<String, dynamic>();
      _latestState = state;
      _stateController.add(state);
      _deriveTraceFromState(state);
      return;
    }

    if (type == 'tool_call') {
      final event = ToolCallEvent(
        toolCallId: message['toolCallId'] as String? ?? _uuid.v4(),
        toolName: message['toolName'] as String? ?? 'unknown',
        input: (message['input'] as Map?)?.cast<String, dynamic>() ?? {},
      );
      _toolCallController.add(event);
      _emitTrace(
        TraceEventType.clientToolCall,
        'Client tool requested: ${event.toolName}',
        metadata: {'toolCallId': event.toolCallId},
      );
    }
  }

  void _handleRpc(Map<String, dynamic> message) {
    final id = message['id'] as String?;
    if (id == null) return;

    final completer = _pendingRpc.remove(id);
    if (completer == null) return;

    final success = message['success'] as bool? ?? false;
    if (success) {
      completer.complete(message['result']);
    } else {
      completer.completeError(message['error'] ?? 'RPC failed');
    }
  }

  void _deriveTraceFromState(Map<String, dynamic> state) {
    final status = state['status'] as String?;
    if (status != null) {
      _emitTrace(TraceEventType.status, 'Agent status: $status');
    }

    final messages = state['messages'];
    if (messages is List && messages.isNotEmpty) {
      final last = messages.last;
      if (last is Map) {
        final role = last['role'] as String? ?? 'agent';
        final content = last['content'];
        final text = content is String
            ? content
            : content is List
                ? content
                    .whereType<Map>()
                    .map((part) => part['text'])
                    .whereType<String>()
                    .join('\n')
                : content?.toString() ?? '';
        if (text.isNotEmpty) {
          _emitTrace(
            role == 'user'
                ? TraceEventType.userPrompt
                : TraceEventType.agentResponse,
            text,
          );
        }
      }
    }

    final activeTools = state['activeToolCalls'];
    if (activeTools is List) {
      for (final tool in activeTools) {
        if (tool is Map) {
          _emitTrace(
            TraceEventType.serverToolCall,
            'Server tool: ${tool['name'] ?? tool['toolName'] ?? 'unknown'}',
          );
        }
      }
    }
  }

  void _scheduleReconnect() {
    if (_intentionalDisconnect) return;
    _reconnectTimer?.cancel();
    final delayMs = min(
      AppConfig.reconnectMaxDelay.inMilliseconds,
      AppConfig.reconnectBaseDelay.inMilliseconds * pow(2, _reconnectAttempt).toInt(),
    );
    _reconnectAttempt++;
    _reconnectTimer = Timer(Duration(milliseconds: delayMs), _openSocket);
  }

  void _send(Map<String, dynamic> payload) {
    final channel = _channel;
    if (channel == null) return;
    channel.sink.add(jsonEncode(payload));
  }

  void _setStatus(ConnectionStatus status) {
    _status = status;
    _connectionController.add(status);
  }

  void _emitTrace(
    TraceEventType type,
    String message, {
    Map<String, dynamic> metadata = const {},
  }) {
    _traceController.add(
      TraceEvent(
        id: _uuid.v4(),
        type: type,
        message: message,
        timestamp: DateTime.now(),
        metadata: metadata,
      ),
    );
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _stateController.close();
    _toolCallController.close();
    _connectionController.close();
    _traceController.close();
  }
}
