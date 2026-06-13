import '../../core/config.dart';
import 'agent_host_validator.dart';

Uri buildAgentWebSocketUri({
  required String host,
  required String sessionId,
}) {
  final base = parseAgentHost(host);
  final uri = Uri.parse(base);
  final wsScheme = uri.scheme == 'http' ? 'ws' : 'wss';
  return Uri(
    scheme: wsScheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: '/agents/${AppConfig.agentClassName}/$sessionId',
  );
}

Map<String, String> buildAgentAuthHeaders(String? authToken) {
  if (authToken == null || authToken.isEmpty) return const {};
  return {'Authorization': 'Bearer $authToken'};
}

String describeAgentConnectionTarget(Uri uri) {
  return '${uri.scheme}://${uri.authority}${uri.path}';
}
