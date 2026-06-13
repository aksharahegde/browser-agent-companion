import 'package:cua_companion/core/config.dart';
import 'package:cua_companion/services/agent/agent_connection_uri.dart';
import 'package:cua_companion/services/agent/agent_host_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildAgentWebSocketUri', () {
    test('does not include auth token in query string', () {
      final uri = buildAgentWebSocketUri(
        host: 'https://example.workers.dev',
        sessionId: 'session-123',
      );

      expect(uri.queryParameters, isEmpty);
      expect(
        uri.toString(),
        'wss://example.workers.dev/agents/${AppConfig.agentClassName}/session-123',
      );
    });

    test('uses ws for local http hosts', () {
      final uri = buildAgentWebSocketUri(
        host: 'http://localhost:8787',
        sessionId: 'session-123',
      );

      expect(uri.scheme, 'ws');
      expect(uri.host, 'localhost');
      expect(uri.port, 8787);
    });

    test('rejects insecure remote hosts', () {
      expect(
        () => buildAgentWebSocketUri(
          host: 'http://example.workers.dev',
          sessionId: 'session-123',
        ),
        throwsA(isA<AgentHostValidationException>()),
      );
    });
  });

  group('buildAgentAuthHeaders', () {
    test('returns Bearer header when token is set', () {
      expect(
        buildAgentAuthHeaders('secret-token'),
        {'Authorization': 'Bearer secret-token'},
      );
    });

    test('returns empty map when token is missing', () {
      expect(buildAgentAuthHeaders(null), isEmpty);
      expect(buildAgentAuthHeaders(''), isEmpty);
    });
  });
}
