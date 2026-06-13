import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/config.dart';
import 'core/logging.dart';
import 'shared/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  await hotKeyManager.unregisterAll();

  const windowOptions = WindowOptions(
    size: Size(AppConfig.overlayDefaultWidth, AppConfig.overlayDefaultHeight),
    minimumSize: Size(AppConfig.overlayDefaultWidth, AppConfig.overlayDefaultHeight),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
    alwaysOnTop: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setBackgroundColor(Colors.transparent);
    await windowManager.setHasShadow(false);
  });

  runApp(
    const ProviderScope(
      child: _BootstrapApp(),
    ),
  );
}

class _BootstrapApp extends ConsumerStatefulWidget {
  const _BootstrapApp();

  @override
  ConsumerState<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends ConsumerState<_BootstrapApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    try {
      final settingsNotifier = ref.read(settingsProvider.notifier);
      await settingsNotifier.load();

      var settings = ref.read(settingsProvider);
      await ref.read(sessionServiceProvider).ensureInitialized();
      settings = ref.read(settingsProvider);

      final agent = ref.read(agentSessionServiceProvider);
      final localTools = ref.read(localToolExecutorProvider);
      agent.onToolCallRequested = (event) async {
        final output = await localTools.execute(event);
        await agent.submitToolResult(event.toolCallId, output);
      };

      await agent.configure(settings);

      final workflowService = ref.read(workflowServiceProvider);
      await workflowService.seedDefaultsIfEmpty();
      await workflowService.registerAllHotkeys();

      final lifecycle = ref.read(appLifecycleServiceProvider);
      await lifecycle.registerQuitHotkey(lifecycle.quitApp);

      await windowManager.hide();
      logInfo('CUA Companion started');
    } catch (error, stackTrace) {
      logError('Bootstrap failed', error: error, stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const CuaCompanionApp();
  }
}
