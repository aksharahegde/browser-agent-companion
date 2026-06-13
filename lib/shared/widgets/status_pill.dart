import 'package:flutter/material.dart';

import '../../data/models/trace_event.dart';
import '../theme.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.dotColor,
    this.subtitle,
  })  : _status = null,
        _host = null;

  const StatusPill.connection({
    super.key,
    required ConnectionStatus status,
    required String host,
  })  : _status = status,
        _host = host,
        label = '',
        dotColor = null,
        subtitle = null;

  final String label;
  final Color? dotColor;
  final String? subtitle;
  final ConnectionStatus? _status;
  final String? _host;

  String get _displayHost {
    final host = _host ?? '';
    final uri = Uri.tryParse(host);
    if (uri != null && uri.host.isNotEmpty) return uri.host;
    return host;
  }

  (String, Color) _connectionInfo(ConnectionStatus status) {
    return switch (status) {
      ConnectionStatus.connected => ('Connected', AppColors.statusConnected),
      ConnectionStatus.connecting => ('Connecting', AppColors.statusConnecting),
      ConnectionStatus.reconnecting =>
        ('Reconnecting', AppColors.statusConnecting),
      ConnectionStatus.error => ('Error', AppColors.statusError),
      ConnectionStatus.disconnected => ('Offline', AppColors.statusOffline),
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final status = _status;
    final (resolvedLabel, resolvedColor) = status != null
        ? _connectionInfo(status)
        : (label, dotColor ?? AppColors.textMuted);
    final detail = status != null ? ' · $_displayHost' : (subtitle ?? '');

    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tokens.glassFill(0.5),
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: resolvedColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$resolvedLabel$detail',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: tokens.textMuted,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
