import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

import '../../core/logging.dart';
import '../../data/models/trace_event.dart';
import 'agent_backend_probe.dart';

class AgentHttpRunClient {
  AgentHttpRunClient({required this.host});

  final String host;
  final _uuid = const Uuid();
  final _connectionController =
      StreamController<ConnectionStatus>.broadcast();
  final _traceController = StreamController<TraceEvent>.broadcast();

  ConnectionStatus _status = ConnectionStatus.disconnected;
  bool _disposed = false;
  HttpClient? _runClient;
  StreamSubscription<String>? _runSubscription;

  Stream<ConnectionStatus> get onConnectionStatus =>
      _connectionController.stream;
  Stream<TraceEvent> get onTraceEvent => _traceController.stream;
  ConnectionStatus get status => _status;

  Future<void> connect() async {
    if (_disposed) return;
    _setStatus(ConnectionStatus.connecting);
    try {
      final uri = Uri.parse('${normalizeAgentHost(host)}/status');
      final client = HttpClient();
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 8));
      final response = await request.close().timeout(const Duration(seconds: 8));
      final ok = response.statusCode == 200;
      await response.drain();
      client.close(force: true);
      if (!ok) {
        _setStatus(ConnectionStatus.error);
        return;
      }
      _setStatus(ConnectionStatus.connected);
      _emitTrace(TraceEventType.status, 'Connected to worker (HTTP /run API)');
    } catch (error, stackTrace) {
      logError('HTTP status check failed', error: error, stackTrace: stackTrace);
      _setStatus(ConnectionStatus.error);
    }
  }

  Future<void> disconnect() async {
    await cancelRun();
    _setStatus(ConnectionStatus.disconnected);
  }

  Future<void> run(String prompt, AgentRunContext context) async {
    if (_disposed) {
      throw StateError('Agent client disposed');
    }
    if (_status != ConnectionStatus.connected) {
      throw StateError('Agent is not connected');
    }

    await cancelRun();

    final goal = _buildGoal(prompt, context);
    _emitTrace(TraceEventType.userPrompt, goal);

    final client = HttpClient();
    _runClient = client;
    final completer = Completer<void>();

    try {
      final uri = Uri.parse('${normalizeAgentHost(host)}/run');
      final request = await client.postUrl(uri).timeout(const Duration(seconds: 15));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({'goal': goal}));
      final response = await request.close().timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw HttpException('Run failed with HTTP ${response.statusCode}');
      }

      _runSubscription = response
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          if (!line.startsWith('data: ')) return;
          final payload = line.substring(6).trim();
          if (payload.isEmpty) return;
          try {
            final event = jsonDecode(payload) as Map<String, dynamic>;
            _handleRunEvent(event);
          } catch (error) {
            logError('Failed to parse SSE event', error: error);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(error, stackTrace);
          }
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete();
        },
        cancelOnError: true,
      );

      await completer.future;
    } finally {
      await _runSubscription?.cancel();
      _runSubscription = null;
      client.close(force: true);
      if (identical(_runClient, client)) {
        _runClient = null;
      }
    }
  }

  Future<void> cancelRun() async {
    await _runSubscription?.cancel();
    _runSubscription = null;
    _runClient?.close(force: true);
    _runClient = null;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    cancelRun();
    _connectionController.close();
    _traceController.close();
  }

  String _buildGoal(String prompt, AgentRunContext context) {
    final buffer = StringBuffer(prompt.trim());
    final clipboard = context.clipboardText?.trim();
    if (clipboard != null && clipboard.isNotEmpty) {
      buffer.writeln('\n\nClipboard:\n$clipboard');
    }
    if (context.screenshotBase64 != null &&
        context.screenshotBase64!.isNotEmpty) {
      buffer.writeln(
        '\n\nNote: screenshot attachment is not supported by the HTTP /run API yet.',
      );
    }
    return buffer.toString();
  }

  void _handleRunEvent(Map<String, dynamic> event) {
    final type = event['type'] as String? ?? 'status';
    final (traceType, message) = switch (type) {
      'start' => (
          TraceEventType.status,
          'Run started',
        ),
      'plan' => (
          TraceEventType.serverToolCall,
          'Plan URL: ${event['url'] ?? 'unknown'}',
        ),
      'launching' => (
          TraceEventType.status,
          'Launching browser',
        ),
      'step' => (
          TraceEventType.serverToolCall,
          'Step ${event['step']}: ${event['action'] ?? 'navigate'} → ${event['url'] ?? ''}',
        ),
      'observe' => (
          TraceEventType.serverToolCall,
          'Observed ${event['length'] ?? 0} chars from ${event['url'] ?? 'page'}',
        ),
      'think' => (
          TraceEventType.agentThinking,
          'Decision: ${event['action'] ?? 'unknown'} ${event['next_url'] ?? ''}',
        ),
      'done' => (
          TraceEventType.agentResponse,
          event['summary']?.toString() ?? 'Run completed',
        ),
      'error' => (
          TraceEventType.error,
          event['message']?.toString() ?? 'Unknown error',
        ),
      _ => (TraceEventType.status, jsonEncode(event)),
    };
    _emitTrace(traceType, message);
  }

  void _setStatus(ConnectionStatus status) {
    if (_disposed || _connectionController.isClosed) return;
    _status = status;
    _connectionController.add(status);
  }

  void _emitTrace(TraceEventType type, String message) {
    if (_disposed || _traceController.isClosed) return;
    _traceController.add(
      TraceEvent(
        id: _uuid.v4(),
        type: type,
        message: message,
        timestamp: DateTime.now(),
      ),
    );
  }
}
