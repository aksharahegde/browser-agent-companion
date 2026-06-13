import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/overlay_window_service.dart';
import '../../data/models/agent_session.dart';
import '../../shared/providers.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/glass_list_row.dart';
import '../../shared/widgets/overlay_subnav.dart';

class SessionsPage extends ConsumerWidget {
  const SessionsPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    final activeId = ref.watch(settingsProvider).activeSessionId;
    final dateFormat = DateFormat('MMM d, HH:mm');
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OverlaySubnav(
          title: 'Sessions',
          onBack: onBack,
          onMinimize: () => hideOverlayWindow(ref),
          actions: [
            IconButton(
              tooltip: 'New session',
              onPressed: () => _createSession(context, ref),
              icon: Icon(Icons.add, color: tokens.textMuted),
            ),
          ],
        ),
        Expanded(
          child: sessions.when(
            data: (items) {
              if (items.isEmpty) {
                return Center(
                  child: FilledButton(
                    onPressed: () => _createSession(context, ref),
                    child: const Text('Create session'),
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.all(tokens.spaceMd),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: tokens.spaceSm),
                itemBuilder: (context, index) {
                  final session = items[index];
                  final isActive = session.id == activeId;
                  return GlassListRow(
                    onTap: () => _switchSession(context, ref, session),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            session.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isActive)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(
                                tokens.radiusMd,
                              ),
                            ),
                            child: Text(
                              'Active',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      'Last active ${dateFormat.format(session.lastActiveAt.toLocal())}',
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz, color: tokens.textMuted),
                      onSelected: (value) async {
                        switch (value) {
                          case 'rename':
                            await _renameSession(context, ref, session);
                          case 'delete':
                            await _deleteSession(context, ref, session);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'rename', child: Text('Rename')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
          ),
        ),
      ],
    );
  }

  Future<void> _createSession(BuildContext context, WidgetRef ref) async {
    await ref.read(sessionServiceProvider).createAndSwitchSession();
    ref.invalidate(sessionsProvider);
    ref.invalidate(runHistoryProvider);
    ref.read(sessionsVisibleProvider.notifier).state = false;
  }

  Future<void> _switchSession(
    BuildContext context,
    WidgetRef ref,
    AgentSession session,
  ) async {
    await ref.read(sessionServiceProvider).switchActiveSession(session.id);
    ref.invalidate(sessionsProvider);
    ref.invalidate(runHistoryProvider);
    ref.read(sessionsVisibleProvider.notifier).state = false;
  }

  Future<void> _renameSession(
    BuildContext context,
    WidgetRef ref,
    AgentSession session,
  ) async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => _RenameSessionDialog(initialTitle: session.title),
    );
    if (title == null) return;

    await ref.read(sessionServiceProvider).renameSession(session.id, title);
    ref.invalidate(sessionsProvider);
  }

  Future<void> _deleteSession(
    BuildContext context,
    WidgetRef ref,
    AgentSession session,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete session?'),
        content: Text(
          'Remove "${session.title}" from this device. Backend conversation state is not deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(sessionServiceProvider).deleteSession(session.id);
    ref.invalidate(sessionsProvider);
    ref.invalidate(runHistoryProvider);
  }
}

class _RenameSessionDialog extends StatefulWidget {
  const _RenameSessionDialog({required this.initialTitle});

  final String initialTitle;

  @override
  State<_RenameSessionDialog> createState() => _RenameSessionDialogState();
}

class _RenameSessionDialogState extends State<_RenameSessionDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename session'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Title'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
