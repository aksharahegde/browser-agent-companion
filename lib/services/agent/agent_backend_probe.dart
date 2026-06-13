import 'dart:io';

import '../../core/logging.dart';

String normalizeAgentHost(String host) {
  return host.endsWith('/') ? host.substring(0, host.length - 1) : host;
}

Future<bool> probeHttpRunBackend(String host) async {
  final client = HttpClient();
  try {
    final uri = Uri.parse('${normalizeAgentHost(host)}/status');
    final request = await client.getUrl(uri).timeout(const Duration(seconds: 8));
    final response = await request.close().timeout(const Duration(seconds: 8));
    await response.drain();
    return response.statusCode == 200;
  } catch (error) {
    logInfo('HTTP /status probe failed for $host: $error');
    return false;
  } finally {
    client.close(force: true);
  }
}
