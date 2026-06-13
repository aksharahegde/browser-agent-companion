import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/trace_event.dart';
import '../../data/models/workflow.dart';
import '../../core/overlay_window_service.dart';
import '../../shared/app_messenger.dart';
import '../../shared/providers.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/glass_list_row.dart';
import '../../shared/widgets/overlay_top_bar.dart';
import '../../shared/widgets/panel_section.dart';
import '../../shared/widgets/toggle_row.dart';
import '../../shared/widgets/trace_timeline.dart';

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
      setState(() {
        _connectionStatus = agent.status;
        _trace = agent.currentTrace;
      });
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
    final tokens = context.tokens;

    return Column(
      children: [
        OverlayTopBar(
          connectionStatus: _connectionStatus,
          host: settings.agentHost,
          onMinimize: () => hideOverlayWindow(ref),
          onQuit: () => ref.read(appLifecycleServiceProvider).quitApp(),
          onSessionChanged: () {
            if (mounted) setState(() => _promptController.clear());
          },
        ),
        SizedBox(height: tokens.spaceSm),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PanelSection(
                flex: 2,
                title: 'Prompt',
                child: _buildPromptPanel(workflowsAsync),
              ),
              SizedBox(width: tokens.spaceMd),
              PanelSection(
                flex: 3,
                title: 'Trace',
                child: TraceTimeline(events: _trace),
              ),
              SizedBox(width: tokens.spaceMd),
              PanelSection(
                flex: 2,
                title: 'History',
                child: _buildHistoryPanel(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromptPanel(AsyncValue<List<WorkflowItem>> workflowsAsync) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        workflowsAsync.when(
          data: (workflows) => DropdownButtonFormField<WorkflowItem?>(
            isExpanded: true,
            value: _selectedWorkflow,
            decoration: const InputDecoration(labelText: 'Workflow'),
            selectedItemBuilder: (context) => [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Custom prompt',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ...workflows.map(
                (w) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${w.icon} ${w.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Custom prompt'),
              ),
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
        SizedBox(height: tokens.spaceMd),
        TextField(
          controller: _promptController,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Prompt',
            hintText: 'Ask the agent to do something…',
          ),
        ),
        SizedBox(height: tokens.spaceSm),
        ToggleRow(
          title: 'Attach clipboard',
          value: _attachClipboard,
          onChanged: (v) => setState(() => _attachClipboard = v),
        ),
        ToggleRow(
          title: 'Attach screenshot',
          value: _attachScreenshot,
          onChanged: (v) => setState(() => _attachScreenshot = v),
        ),
        const Spacer(),
        Wrap(
          spacing: tokens.spaceSm,
          runSpacing: tokens.spaceSm,
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
    );
  }

  Widget _buildHistoryPanel() {
    final history = ref.watch(runHistoryProvider);
    final tokens = context.tokens;

    return history.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Text(
              'Run history will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textMuted,
                  ),
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: entries.length,
          separatorBuilder: (_, __) => SizedBox(height: tokens.spaceSm),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return GlassListRow(
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
              trailing: HistoryStatusChip(status: entry.status),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }

  Future<void> _runPrompt() async {
    final workflowService = ref.read(workflowServiceProvider);
    final sessionService = ref.read(sessionServiceProvider);
    final settings = ref.read(settingsProvider);
    final sessionId = settings.activeSessionId;
    if (sessionId.isEmpty) return;

    try {
      String promptForTitle = _promptController.text.trim();
      if (_selectedWorkflow != null) {
        promptForTitle = _promptController.text.isEmpty
            ? _selectedWorkflow!.promptTemplate
            : _promptController.text;
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
        promptForTitle = prompt;
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
      await sessionService.maybeAutoTitle(sessionId, promptForTitle);
      await sessionService.touchActiveSession();
      ref.invalidate(sessionsProvider);
      ref.invalidate(runHistoryProvider);
    } catch (error) {
      if (mounted) {
        showAppSnackBar('Run failed: $error');
      }
    }
  }
}

final workflowsProvider = FutureProvider<List<WorkflowItem>>((ref) async {
  final service = ref.watch(workflowServiceProvider);
  await service.seedDefaultsIfEmpty();
  return service.loadWorkflows();
});
