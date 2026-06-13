import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/trace_event.dart';
import '../../data/models/workflow.dart';
import '../../core/overlay_window_service.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/connection_badge.dart';

class OverlayWindow extends ConsumerStatefulWidget {
  const OverlayWindow({super.key});

  @override
  ConsumerState<OverlayWindow> createState() => _OverlayWindowState();
}

class _OverlayWindowState extends ConsumerState<OverlayWindow> {
  final _promptController = TextEditingController();
  bool _attachScreenshot = false;
  bool _attachClipboard = true;
  WorkflowItem? _selectedWorkflow;
  List<TraceEvent> _trace = [];
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final agent = ref.read(agentSessionServiceProvider);
      agent.connectionStatus.listen((status) {
        if (mounted) setState(() => _connectionStatus = status);
      });
      agent.traceEvents.listen((events) {
        if (mounted) setState(() => _trace = events);
      });
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final workflowsAsync = ref.watch(workflowsProvider);

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor.withValues(
            alpha: settings.overlayOpacity,
          ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF34373F)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildTitleBar(context, settings.agentHost),
          const Divider(height: 1),
          Expanded(
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildPromptPanel(workflowsAsync)),
                const VerticalDivider(width: 1),
                Expanded(flex: 3, child: TraceTimeline(events: _trace)),
                const VerticalDivider(width: 1),
                Expanded(flex: 2, child: _buildHistoryPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context, String host) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Flexible(
            child: Text(
              'CUA Companion',
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          ConnectionBadge(status: _connectionStatus, host: host),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (value) async {
              switch (value) {
                case 'minimize':
                  await hideOverlayWindow(ref);
                case 'quit':
                  await ref.read(appLifecycleServiceProvider).quitApp();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'minimize', child: Text('Minimize to menu bar')),
              PopupMenuItem(value: 'quit', child: Text('Quit')),
            ],
            child: const Icon(Icons.more_horiz),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptPanel(AsyncValue<List<WorkflowItem>> workflowsAsync) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          workflowsAsync.when(
            data: (workflows) => DropdownButtonFormField<WorkflowItem?>(
              value: _selectedWorkflow,
              decoration: const InputDecoration(labelText: 'Workflow'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Custom prompt')),
                ...workflows.map(
                  (w) => DropdownMenuItem(
                    value: w,
                    child: Text(
                      '${w.icon} ${w.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _selectedWorkflow = value),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Failed to load workflows: $e'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _promptController,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Prompt',
              hintText: 'Ask the agent to do something…',
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text('Attach clipboard'),
            value: _attachClipboard,
            onChanged: (v) => setState(() => _attachClipboard = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text('Attach screenshot'),
            value: _attachScreenshot,
            onChanged: (v) => setState(() => _attachScreenshot = v),
          ),
          const Spacer(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () =>
                    ref.read(agentSessionServiceProvider).clearTrace(),
                child: const Text('Clear'),
              ),
              OutlinedButton(
                onPressed: () =>
                    ref.read(agentSessionServiceProvider).cancelRun(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: _runPrompt,
                child: const Text('Run'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel() {
    final history = ref.watch(runHistoryProvider);
    return history.when(
      data: (entries) => ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            child: ListTile(
              dense: true,
              title: Text(
                entry.workflowName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                entry.summary.isEmpty ? entry.prompt : entry.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: SizedBox(
                width: 56,
                child: Text(
                  entry.status,
                  style: const TextStyle(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }

  Future<void> _runPrompt() async {
    final workflowService = ref.read(workflowServiceProvider);
    final settings = ref.read(settingsProvider);

    try {
      if (_selectedWorkflow != null) {
        await workflowService.runWorkflow(
          _selectedWorkflow!,
          overridePrompt: _promptController.text.isEmpty
              ? null
              : _promptController.text,
          settings: settings.copyWith(
            defaultAttachClipboard: _attachClipboard,
            defaultAttachScreenshot: _attachScreenshot,
          ),
        );
      } else {
        final prompt = _promptController.text.trim();
        if (prompt.isEmpty) return;
        final temp = WorkflowItem(
          id: 'custom',
          name: 'Custom',
          promptTemplate: prompt,
          icon: '✨',
          sortOrder: 0,
          attachScreenshot: _attachScreenshot,
          attachClipboard: _attachClipboard,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await workflowService.runWorkflow(temp, settings: settings);
      }
      ref.invalidate(runHistoryProvider);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Run failed: $error')),
        );
      }
    }
  }
}

final workflowsProvider = FutureProvider<List<WorkflowItem>>((ref) async {
  final service = ref.watch(workflowServiceProvider);
  await service.seedDefaultsIfEmpty();
  return service.loadWorkflows();
});

final runHistoryProvider = FutureProvider((ref) async {
  final db = ref.watch(databaseProvider);
  return db.loadRunHistory();
});
