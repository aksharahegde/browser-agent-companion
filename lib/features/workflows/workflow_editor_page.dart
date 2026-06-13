import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/overlay_window_service.dart';
import '../../data/models/workflow.dart';
import '../../shared/providers.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/glass_list_row.dart';
import '../../shared/widgets/overlay_subnav.dart';
import '../../shared/widgets/toggle_row.dart';
import '../overlay/overlay_window.dart';

class WorkflowEditorPage extends ConsumerStatefulWidget {
  const WorkflowEditorPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  ConsumerState<WorkflowEditorPage> createState() => _WorkflowEditorPageState();
}

class _WorkflowEditorPageState extends ConsumerState<WorkflowEditorPage> {
  @override
  Widget build(BuildContext context) {
    final workflows = ref.watch(workflowsProvider);
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OverlaySubnav(
          title: 'Workflows',
          onBack: widget.onBack,
          onMinimize: () => hideOverlayWindow(ref),
          actions: [
            IconButton(
              tooltip: 'New workflow',
              onPressed: () => _openEditor(context),
              icon: Icon(Icons.add, color: tokens.textMuted),
            ),
          ],
        ),
        Divider(height: 1, color: tokens.hairline),
        Expanded(
          child: workflows.when(
            data: (items) => ReorderableListView.builder(
              padding: EdgeInsets.all(tokens.spaceMd),
              itemCount: items.length,
              onReorder: (oldIndex, newIndex) async {
                if (newIndex > oldIndex) newIndex -= 1;
                final list = [...items];
                final item = list.removeAt(oldIndex);
                list.insert(newIndex, item);
                final service = ref.read(workflowServiceProvider);
                for (var i = 0; i < list.length; i++) {
                  await service.saveWorkflow(list[i].copyWith(sortOrder: i));
                }
                ref.invalidate(workflowsProvider);
              },
              itemBuilder: (context, index) {
                final workflow = items[index];
                return Padding(
                  key: ValueKey(workflow.id),
                  padding: EdgeInsets.only(bottom: tokens.spaceSm),
                  child: GlassListRow(
                    leading: Text(
                      workflow.icon,
                      style: const TextStyle(fontSize: 18),
                    ),
                    title: Text(
                      workflow.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      workflow.hotkey ?? 'No shortcut',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Run',
                          icon: Icon(Icons.play_arrow, color: tokens.textMuted),
                          onPressed: () => ref
                              .read(workflowServiceProvider)
                              .runWorkflow(workflow),
                        ),
                        IconButton(
                          tooltip: 'Edit',
                          icon: Icon(Icons.edit_outlined, color: tokens.textMuted),
                          onPressed: () =>
                              _openEditor(context, workflow: workflow),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          icon: Icon(Icons.delete_outline, color: tokens.textMuted),
                          onPressed: () async {
                            await ref
                                .read(workflowServiceProvider)
                                .deleteWorkflow(workflow.id);
                            ref.invalidate(workflowsProvider);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
          ),
        ),
      ],
    );
  }

  Future<void> _openEditor(BuildContext context, {WorkflowItem? workflow}) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _WorkflowDialog(
        workflow: workflow,
        onSaved: () => ref.invalidate(workflowsProvider),
      ),
    );
  }
}

class _WorkflowDialog extends ConsumerStatefulWidget {
  const _WorkflowDialog({this.workflow, required this.onSaved});

  final WorkflowItem? workflow;
  final VoidCallback onSaved;

  @override
  ConsumerState<_WorkflowDialog> createState() => _WorkflowDialogState();
}

class _WorkflowDialogState extends ConsumerState<_WorkflowDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _promptController;
  late final TextEditingController _iconController;
  late final TextEditingController _hotkeyController;
  late bool _attachClipboard;
  late bool _attachScreenshot;

  @override
  void initState() {
    super.initState();
    final w = widget.workflow;
    _nameController = TextEditingController(text: w?.name ?? '');
    _promptController = TextEditingController(text: w?.promptTemplate ?? '');
    _iconController = TextEditingController(text: w?.icon ?? '⚡');
    _hotkeyController = TextEditingController(text: w?.hotkey ?? '');
    _attachClipboard = w?.attachClipboard ?? true;
    _attachScreenshot = w?.attachScreenshot ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _promptController.dispose();
    _iconController.dispose();
    _hotkeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AlertDialog(
      title: Text(widget.workflow == null ? 'New workflow' : 'Edit workflow'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: tokens.spaceSm),
            TextField(
              controller: _iconController,
              decoration: const InputDecoration(labelText: 'Icon'),
            ),
            SizedBox(height: tokens.spaceSm),
            TextField(
              controller: _hotkeyController,
              decoration: const InputDecoration(
                labelText: 'Hotkey (e.g. cmd+shift+1)',
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            TextField(
              controller: _promptController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Prompt template',
                hintText: 'Use {{clipboard}} placeholder',
              ),
            ),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final workflow = WorkflowItem(
      id: widget.workflow?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      promptTemplate: _promptController.text.trim(),
      icon: _iconController.text.trim().isEmpty
          ? '⚡'
          : _iconController.text.trim(),
      sortOrder: widget.workflow?.sortOrder ?? 999,
      attachScreenshot: _attachScreenshot,
      attachClipboard: _attachClipboard,
      createdAt: widget.workflow?.createdAt ?? now,
      updatedAt: now,
      hotkey: _hotkeyController.text.trim().isEmpty
          ? null
          : _hotkeyController.text.trim(),
    );

    await ref.read(workflowServiceProvider).saveWorkflow(workflow);
    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }
}
