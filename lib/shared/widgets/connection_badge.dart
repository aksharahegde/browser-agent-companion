import 'package:flutter/material.dart';

import '../../data/models/trace_event.dart';

class ConnectionBadge extends StatelessWidget {
  const ConnectionBadge({super.key, required this.status, required this.host});

  final ConnectionStatus status;
  final String host;

  String get _displayHost {
    final uri = Uri.tryParse(host);
    if (uri != null && uri.host.isNotEmpty) return uri.host;
    return host;
  }

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ConnectionStatus.connected => ('Connected', Colors.greenAccent),
      ConnectionStatus.connecting => ('Connecting', Colors.amberAccent),
      ConnectionStatus.reconnecting => ('Reconnecting', Colors.amberAccent),
      ConnectionStatus.error => ('Error', Colors.redAccent),
      ConnectionStatus.disconnected => ('Offline', Colors.grey),
    };

    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$label · $_displayHost',
              style: Theme.of(context).textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class TraceTimeline extends StatelessWidget {
  const TraceTimeline({super.key, required this.events});

  final List<TraceEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Text(
          'Agent trace will appear here',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _icon(event.type),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label(event.type),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Menlo',
                            fontFamilyFallback: const ['monospace'],
                          ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _icon(TraceEventType type) => switch (type) {
        TraceEventType.userPrompt => '›',
        TraceEventType.agentThinking => '…',
        TraceEventType.serverToolCall => '🌐',
        TraceEventType.clientToolCall => '💻',
        TraceEventType.clientToolResult => '✓',
        TraceEventType.agentResponse => '◆',
        TraceEventType.error => '!',
        TraceEventType.status => '•',
      };

  String _label(TraceEventType type) => switch (type) {
        TraceEventType.userPrompt => 'Prompt',
        TraceEventType.agentThinking => 'Thinking',
        TraceEventType.serverToolCall => 'Browser tool',
        TraceEventType.clientToolCall => 'Local tool',
        TraceEventType.clientToolResult => 'Tool result',
        TraceEventType.agentResponse => 'Response',
        TraceEventType.error => 'Error',
        TraceEventType.status => 'Status',
      };
}
