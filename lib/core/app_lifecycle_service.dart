import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../services/agent/agent_session_service.dart';
import '../services/workflows/workflow_service.dart';
import 'logging.dart';

typedef QuitCallback = Future<void> Function();

class AppLifecycleService {
  AppLifecycleService({
    required AgentSessionService agentSessionService,
    required WorkflowService workflowService,
    required Future<void> Function() onBeforeQuit,
  })  : _agentSessionService = agentSessionService,
        _workflowService = workflowService,
        _onBeforeQuit = onBeforeQuit;

  final AgentSessionService _agentSessionService;
  final WorkflowService _workflowService;
  final Future<void> Function() _onBeforeQuit;
  bool _isQuitting = false;

  Future<void> quitApp() async {
    if (_isQuitting) return;
    _isQuitting = true;
    logInfo('Quitting application');

    try {
      await _agentSessionService.cancelRun();
      await _agentSessionService.disconnect();
      await _workflowService.unregisterAllHotkeys();
      await trayManager.destroy();
      await _onBeforeQuit();
      await windowManager.destroy();
    } catch (error, stackTrace) {
      logError('Error during quit', error: error, stackTrace: stackTrace);
    } finally {
      exit(0);
    }
  }

  Future<void> registerQuitHotkey(Future<void> Function() onQuit) async {
    await hotKeyManager.register(
      HotKey(
        key: PhysicalKeyboardKey.keyQ,
        modifiers: [HotKeyModifier.meta],
        scope: HotKeyScope.system,
      ),
      keyDownHandler: (_) async => onQuit(),
    );
  }
}
