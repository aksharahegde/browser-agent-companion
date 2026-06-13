import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/config.dart';
import '../../data/models/workflow.dart';
import '../../shared/providers.dart';
import '../overlay/overlay_window.dart';
import '../settings/settings_page.dart';
import '../workflows/workflow_editor_page.dart';

class MenuBarController extends ConsumerStatefulWidget {
  const MenuBarController({super.key});

  @override
  ConsumerState<MenuBarController> createState() => _MenuBarControllerState();
}

class _MenuBarControllerState extends ConsumerState<MenuBarController>
    with TrayListener {
  var _trayReady = false;

  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initTray());
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }

  Future<void> _initTray() async {
    try {
      await trayManager.setIcon('assets/icons/tray_icon.png');
      await _rebuildMenu();
      if (mounted) setState(() => _trayReady = true);
    } catch (error, stackTrace) {
      debugPrint('Tray init failed: $error\n$stackTrace');
    }
  }

  Future<void> _rebuildMenu() async {
    final workflows = await ref.read(workflowServiceProvider).loadWorkflows();
    final items = <MenuItem>[
      MenuItem(
        key: 'overlay',
        label: 'Open Overlay',
      ),
      MenuItem(
        key: 'workflows',
        label: 'Manage Workflows',
      ),
      MenuItem(
        key: 'settings',
        label: 'Settings',
      ),
      MenuItem.separator(),
      ...workflows.map(
        (WorkflowItem w) => MenuItem(
          key: 'workflow_${w.id}',
          label: '${w.icon} ${w.name}',
        ),
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'quit',
        label: 'Quit CUA Companion',
      ),
    ];
    await trayManager.setContextMenu(Menu(items: items));
  }

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'overlay':
        await _showOverlay();
      case 'workflows':
        await _showWorkflows();
      case 'settings':
        await _showSettings();
      case 'quit':
        await ref.read(appLifecycleServiceProvider).quitApp();
      default:
        if (menuItem.key?.startsWith('workflow_') == true) {
          final id = menuItem.key!.replaceFirst('workflow_', '');
          final workflows =
              await ref.read(workflowServiceProvider).loadWorkflows();
          final workflow = workflows.where((w) => w.id == id).firstOrNull;
          if (workflow != null) {
            await _showOverlay();
            await ref.read(workflowServiceProvider).runWorkflow(workflow);
          }
        }
    }
  }

  Future<void> _showOverlay() async {
    ref.read(overlayVisibleProvider.notifier).state = true;
    await windowManager.setAsFrameless();
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setAlwaysOnTop(true);
  }

  Future<void> _hideOverlay() async {
    ref.read(overlayVisibleProvider.notifier).state = false;
    ref.read(settingsVisibleProvider.notifier).state = false;
    ref.read(workflowsVisibleProvider.notifier).state = false;
    await windowManager.hide();
  }

  Future<void> _showSettings() async {
    ref.read(settingsVisibleProvider.notifier).state = true;
    ref.read(workflowsVisibleProvider.notifier).state = false;
    await _showOverlay();
  }

  Future<void> _showWorkflows() async {
    ref.read(workflowsVisibleProvider.notifier).state = true;
    ref.read(settingsVisibleProvider.notifier).state = false;
    await _showOverlay();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(workflowsProvider, (_, __) {
      if (_trayReady) _rebuildMenu();
    });

    final showOverlay = ref.watch(overlayVisibleProvider);
    final showSettings = ref.watch(settingsVisibleProvider);
    final showWorkflows = ref.watch(workflowsVisibleProvider);

    Widget child = const OverlayWindow();
    if (showSettings) {
      child = const SettingsPage();
    } else if (showWorkflows) {
      child = const WorkflowEditorPage();
    }

    return SizedBox(
      width: AppConfig.overlayDefaultWidth,
      height: AppConfig.overlayDefaultHeight,
      child: showOverlay
          ? Scaffold(
              body: Column(
                children: [
                  if (showSettings || showWorkflows)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(settingsVisibleProvider.notifier)
                                  .state = false;
                              ref
                                  .read(workflowsVisibleProvider.notifier)
                                  .state = false;
                            },
                            child: const Text('Back to overlay'),
                          ),
                          TextButton(
                            onPressed: _hideOverlay,
                            child: const Text('Minimize'),
                          ),
                        ],
                      ),
                    ),
                  Expanded(child: child),
                ],
              ),
            )
          : const ColoredBox(color: Color(0xFF1A1B1E)),
    );
  }
}
