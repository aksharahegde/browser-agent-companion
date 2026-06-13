class AgentHostValidationException implements Exception {
  AgentHostValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

bool isLocalAgentHost(String host) {
  final normalized = host.toLowerCase();
  return normalized == 'localhost' ||
      normalized == '127.0.0.1' ||
      normalized == '[::1]' ||
      normalized == '::1';
}

/// Validates and returns a normalized agent base URL without a trailing slash.
String parseAgentHost(String host) {
  final trimmed = host.trim();
  if (trimmed.isEmpty) {
    throw AgentHostValidationException('Agent host URL is required');
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    throw AgentHostValidationException('Enter a valid agent host URL');
  }

  if (uri.scheme != 'http' && uri.scheme != 'https') {
    throw AgentHostValidationException('Agent host must use http or https');
  }

  if (!isLocalAgentHost(uri.host) && uri.scheme != 'https') {
    throw AgentHostValidationException(
      'Remote agent hosts must use https',
    );
  }

  return normalizeAgentHost(trimmed);
}

String normalizeAgentHost(String host) {
  return host.endsWith('/') ? host.substring(0, host.length - 1) : host;
}

Uri agentHostUri(String host, String path) {
  final base = parseAgentHost(host);
  final normalizedPath = path.startsWith('/') ? path : '/$path';
  return Uri.parse('$base$normalizedPath');
}
