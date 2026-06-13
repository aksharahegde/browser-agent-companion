import 'dart:io';

import '../../core/logging.dart';
import 'agent_connection_uri.dart';
import 'agent_host_validator.dart';

Future<bool> probeHttpRunBackend(
  String host, {
  String? authToken,
}) async {
  final client = HttpClient();
  try {
    final uri = agentHostUri(host, '/status');
    final request = await client.getUrl(uri).timeout(const Duration(seconds: 8));
    for (final entry in buildAgentAuthHeaders(authToken).entries) {
      request.headers.set(entry.key, entry.value);
    }
    final response = await request.close().timeout(const Duration(seconds: 8));
    await response.drain();
    return response.statusCode == 200;
  } catch (error) {
    logInfo('HTTP /status probe failed for ${parseAgentHost(host)}: $error');
    return false;
  } finally {
    client.close(force: true);
  }
}
