import 'package:cua_companion/services/agent/agent_host_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseAgentHost', () {
    test('accepts https remote hosts', () {
      expect(
        parseAgentHost('https://stateful-browser-agent.workers.dev/'),
        'https://stateful-browser-agent.workers.dev',
      );
    });

    test('accepts http localhost', () {
      expect(
        parseAgentHost('http://localhost:8787'),
        'http://localhost:8787',
      );
    });

    test('rejects http remote hosts', () {
      expect(
        () => parseAgentHost('http://example.workers.dev'),
        throwsA(isA<AgentHostValidationException>()),
      );
    });

    test('rejects invalid urls', () {
      expect(
        () => parseAgentHost('not-a-url'),
        throwsA(isA<AgentHostValidationException>()),
      );
    });
  });
}
