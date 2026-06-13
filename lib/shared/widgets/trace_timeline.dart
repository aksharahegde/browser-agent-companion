import 'package:flutter/material.dart';

import '../../data/models/trace_event.dart';
import '../theme.dart';

class TraceTimeline extends StatelessWidget {
  const TraceTimeline({super.key, required this.events});

  final List<TraceEvent> events;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    if (events.isEmpty) {
      return Center(
        child: Text(
          'Agent trace will appear here',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: tokens.textMuted,
              ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final accent = _accentColor(event.type);

        return Padding(
          padding: EdgeInsets.only(bottom: tokens.spaceSm + 2),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 2,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _label(event.type),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: tokens.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Menlo',
                              fontFamilyFallback: const ['monospace'],
                              fontSize: 12,
                            ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _accentColor(TraceEventType type) {
    return switch (type) {
      TraceEventType.userPrompt => AppColors.textMuted,
      TraceEventType.agentThinking => AppColors.textMuted,
      TraceEventType.serverToolCall => AppColors.historyRunning,
      TraceEventType.clientToolCall => AppColors.historyRunning,
      TraceEventType.clientToolResult => AppColors.statusConnected,
      TraceEventType.agentResponse => AppColors.textPrimary,
      TraceEventType.error => AppColors.statusError,
      TraceEventType.status => AppColors.textMuted,
    };
  }

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
