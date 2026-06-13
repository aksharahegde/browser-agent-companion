import '../../core/config.dart';

Uri buildAgentWebSocketUri({
  required String host,
  required String sessionId,
}) {
  final base = host.endsWith('/') ? host.substring(0, host.length - 1) : host;
  final wsBase = base
      .replaceFirst('https://', 'wss://')
      .replaceFirst('http://', 'ws://');
  return Uri.parse(
    '$wsBase/agents/${AppConfig.agentClassName}/$sessionId',
  );
}

Map<String, String> buildAgentAuthHeaders(String? authToken) {
  if (authToken == null || authToken.isEmpty) return const {};
  return {'Authorization': 'Bearer $authToken'};
}

String describeAgentConnectionTarget(Uri uri) {
  return '${uri.scheme}://${uri.authority}${uri.path}';
}
