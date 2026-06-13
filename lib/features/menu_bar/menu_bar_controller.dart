import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tray_manager/tray_manager.dart';

import '../../core/config.dart';
import '../../core/overlay_window_service.dart';
import '../../data/models/workflow.dart';
import '../../shared/app_messenger.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/glass_shell.dart';
import '../overlay/overlay_window.dart';
import '../sessions/sessions_page.dart';
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
        key: 'sessions',
        label: 'Manage Sessions',
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
        await showOverlayWindow(ref);
      case 'workflows':
        await _showWorkflows();
      case 'sessions':
        await _showSessions();
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
            await showOverlayWindow(ref);
            try {
              await ref.read(workflowServiceProvider).runWorkflow(
                    workflow,
                    settings: ref.read(settingsProvider),
                  );
              ref.invalidate(runHistoryProvider);
            } catch (error) {
              if (mounted) {
                showAppSnackBar('Run failed: $error');
              }
            }
          }
        }
    }
  }

  Future<void> _showSettings() async {
    ref.read(settingsVisibleProvider.notifier).show();
    ref.read(workflowsVisibleProvider.notifier).hide();
    ref.read(sessionsVisibleProvider.notifier).hide();
    await showOverlayWindow(ref);
  }

  Future<void> _showWorkflows() async {
    ref.read(workflowsVisibleProvider.notifier).show();
    ref.read(settingsVisibleProvider.notifier).hide();
    ref.read(sessionsVisibleProvider.notifier).hide();
    await showOverlayWindow(ref);
  }

  Future<void> _showSessions() async {
    ref.read(sessionsVisibleProvider.notifier).show();
    ref.read(settingsVisibleProvider.notifier).hide();
    ref.read(workflowsVisibleProvider.notifier).hide();
    await showOverlayWindow(ref);
  }

  void _backToOverlay() {
    ref.read(settingsVisibleProvider.notifier).hide();
    ref.read(workflowsVisibleProvider.notifier).hide();
    ref.read(sessionsVisibleProvider.notifier).hide();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(workflowsProvider, (_, __) {
      if (_trayReady) _rebuildMenu();
    });

    final showOverlay = ref.watch(overlayVisibleProvider);
    final showSettings = ref.watch(settingsVisibleProvider);
    final showWorkflows = ref.watch(workflowsVisibleProvider);
    final showSessions = ref.watch(sessionsVisibleProvider);
    final overlayOpacity = ref.watch(settingsProvider).overlayOpacity;

    if (!showOverlay) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SizedBox(
          width: AppConfig.overlayDefaultWidth,
          height: AppConfig.overlayDefaultHeight,
          child: const SizedBox.shrink(),
        ),
      );
    }

    Widget child = const OverlayWindow();
    if (showSettings) {
      child = SettingsPage(onBack: _backToOverlay);
    } else if (showWorkflows) {
      child = WorkflowEditorPage(onBack: _backToOverlay);
    } else if (showSessions) {
      child = SessionsPage(onBack: _backToOverlay);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        width: AppConfig.overlayDefaultWidth,
        height: AppConfig.overlayDefaultHeight,
        child: GlassShell(
          opacity: overlayOpacity,
          child: child,
        ),
      ),
    );
  }
}
