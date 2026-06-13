import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/config.dart';
import '../../core/logging.dart';
import '../../data/models/trace_event.dart';
import 'agent_connection_uri.dart';

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
  bool _disposed = false;

  Stream<Map<String, dynamic>> get onStateUpdate => _stateController.stream;
  Stream<ToolCallEvent> get onToolCall => _toolCallController.stream;
  Stream<ConnectionStatus> get onConnectionStatus =>
      _connectionController.stream;
  Stream<TraceEvent> get onTraceEvent => _traceController.stream;
  ConnectionStatus get status => _status;
  Map<String, dynamic> get latestState => Map.unmodifiable(_latestState);

  Future<void> connect() async {
    if (_disposed) return;
    _intentionalDisconnect = false;
    await _openSocket();
  }

  Future<void> disconnect() async {
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    final channel = _channel;
    _channel = null;
    _setStatus(ConnectionStatus.disconnected);
    if (channel == null) return;

    try {
      await channel.sink.close().timeout(const Duration(milliseconds: 500));
    } catch (_) {}
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
    if (_disposed || _intentionalDisconnect) return;
    if (_status == ConnectionStatus.connecting) return;
    _setStatus(
      _reconnectAttempt > 0
          ? ConnectionStatus.reconnecting
          : ConnectionStatus.connecting,
    );

    try {
      final uri = buildAgentWebSocketUri(host: host, sessionId: sessionId);
      logInfo('Connecting to ${describeAgentConnectionTarget(uri)}');
      final headers = buildAgentAuthHeaders(authToken);
      _channel = headers.isEmpty
          ? WebSocketChannel.connect(uri)
          : IOWebSocketChannel.connect(uri, headers: headers);
      await _channel!.ready;
      if (_disposed || _intentionalDisconnect) {
        await _channel?.sink.close();
        _channel = null;
        return;
      }
      _reconnectAttempt = 0;
      _setStatus(ConnectionStatus.connected);
      _emitTrace(TraceEventType.status, 'Connected to agent');

      _channel!.stream.listen(
        _handleMessage,
        onError: (Object error) {
          if (_disposed || _intentionalDisconnect) return;
          logError('WebSocket error', error: error);
          _setStatus(ConnectionStatus.error);
          _scheduleReconnect();
        },
        onDone: () {
          if (_disposed || _intentionalDisconnect) return;
          _setStatus(ConnectionStatus.reconnecting);
          _scheduleReconnect();
        },
        cancelOnError: true,
      );
    } catch (error, stackTrace) {
      if (_disposed || _intentionalDisconnect) return;
      logError('Failed to connect', error: error, stackTrace: stackTrace);
      _setStatus(ConnectionStatus.error);
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic raw) {
    if (_disposed) return;
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
      if (!_stateController.isClosed) {
        _stateController.add(state);
      }
      return;
    }

    if (type == 'tool_call') {
      final event = ToolCallEvent(
        toolCallId: message['toolCallId'] as String? ?? _uuid.v4(),
        toolName: message['toolName'] as String? ?? 'unknown',
        input: (message['input'] as Map?)?.cast<String, dynamic>() ?? {},
      );
      if (!_toolCallController.isClosed) {
        _toolCallController.add(event);
      }
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

  void _scheduleReconnect() {
    if (_disposed || _intentionalDisconnect) return;
    _reconnectTimer?.cancel();
    final delayMs = min(
      AppConfig.reconnectMaxDelay.inMilliseconds,
      AppConfig.reconnectBaseDelay.inMilliseconds * pow(2, _reconnectAttempt).toInt(),
    );
    _reconnectAttempt++;
    _reconnectTimer = Timer(Duration(milliseconds: delayMs), () {
      if (_disposed || _intentionalDisconnect) return;
      _openSocket();
    });
  }

  void _send(Map<String, dynamic> payload) {
    final channel = _channel;
    if (channel == null || _disposed) return;
    channel.sink.add(jsonEncode(payload));
  }

  void _setStatus(ConnectionStatus status) {
    if (_disposed || _connectionController.isClosed) return;
    _status = status;
    _connectionController.add(status);
  }

  void _emitTrace(
    TraceEventType type,
    String message, {
    Map<String, dynamic> metadata = const {},
  }) {
    if (_disposed || _traceController.isClosed) return;
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
    if (_disposed) return;
    _disposed = true;
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    final channel = _channel;
    _channel = null;
    try {
      channel?.sink.close();
    } catch (_) {}
    for (final completer in _pendingRpc.values) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('WebSocket client disposed'));
      }
    }
    _pendingRpc.clear();
    _stateController.close();
    _toolCallController.close();
    _connectionController.close();
    _traceController.close();
  }
}
