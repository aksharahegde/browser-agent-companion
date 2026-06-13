import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/agent_session.dart';
import '../../data/models/trace_event.dart';
import '../../shared/providers.dart';
import '../theme.dart';
import 'status_pill.dart';

class OverlayTopBar extends ConsumerWidget {
  const OverlayTopBar({
    super.key,
    required this.connectionStatus,
    required this.host,
    required this.onMinimize,
    required this.onQuit,
    this.onSessionChanged,
  });

  final ConnectionStatus connectionStatus;
  final String host;
  final VoidCallback onMinimize;
  final VoidCallback onQuit;
  final VoidCallback? onSessionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final sessionsAsync = ref.watch(sessionsProvider);
    final activeId = ref.watch(settingsProvider).activeSessionId;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.spaceMd,
        tokens.spaceMd,
        tokens.spaceMd,
        tokens.spaceSm,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'CUA Companion',
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: tokens.spaceSm),
          Expanded(
            flex: 3,
            child: sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) return const SizedBox.shrink();
                final active = sessions.firstWhere(
                  (s) => s.id == activeId,
                  orElse: () => sessions.first,
                );
                return _SessionMenu(
                  sessions: sessions,
                  activeId: activeId,
                  activeTitle: active.title,
                  onSelected: (value) async {
                    if (value == '__new__') {
                      await ref
                          .read(sessionServiceProvider)
                          .createAndSwitchSession();
                    } else {
                      await ref
                          .read(sessionServiceProvider)
                          .switchActiveSession(value);
                    }
                    ref.invalidate(sessionsProvider);
                    ref.invalidate(runHistoryProvider);
                    onSessionChanged?.call();
                  },
                );
              },
              loading: () => const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          SizedBox(width: tokens.spaceSm),
          Flexible(
            flex: 2,
            child: StatusPill.connection(status: connectionStatus, host: host),
          ),
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (value) {
              switch (value) {
                case 'minimize':
                  onMinimize();
                case 'quit':
                  onQuit();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'minimize',
                child: Text('Minimize to menu bar'),
              ),
              PopupMenuItem(value: 'quit', child: Text('Quit')),
            ],
            child: Icon(Icons.more_horiz, color: tokens.textMuted, size: 20),
          ),
        ],
      ),
    );
  }
}

class _SessionMenu extends StatelessWidget {
  const _SessionMenu({
    required this.sessions,
    required this.activeId,
    required this.activeTitle,
    required this.onSelected,
  });

  final List<AgentSession> sessions;
  final String activeId;
  final String activeTitle;
  final Future<void> Function(String value) onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return PopupMenuButton<String>(
      tooltip: 'Session',
      onSelected: onSelected,
      itemBuilder: (context) => [
        ...sessions.map(
          (s) => PopupMenuItem(
            value: s.id,
            child: Text(
              s.id == activeId ? '✓ ${s.title}' : s.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: '__new__', child: Text('New session')),
      ],
      child: DecoratedBox(
        decoration: tokens.chipDecoration(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  activeTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Icon(Icons.expand_more, size: 18, color: tokens.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
