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
    required Future<void> Function() hideOverlay,
  })  : _agentSessionService = agentSessionService,
        _workflowService = workflowService,
        _onBeforeQuit = onBeforeQuit,
        _hideOverlay = hideOverlay;

  final AgentSessionService _agentSessionService;
  final WorkflowService _workflowService;
  final Future<void> Function() _onBeforeQuit;
  final Future<void> Function() _hideOverlay;
  bool _isQuitting = false;

  static const _cleanupTimeout = Duration(seconds: 2);

  Future<void> quitApp() async {
    if (_isQuitting) return;
    _isQuitting = true;
    logInfo('Quitting application');

    unawaited(windowManager.hide());
    try {
      await _hideOverlay().timeout(_cleanupTimeout, onTimeout: () {});
    } catch (_) {}

    try {
      await _runCleanup().timeout(
        _cleanupTimeout,
        onTimeout: () => logInfo('Quit cleanup timed out'),
      );
    } catch (error, stackTrace) {
      logError('Error during quit', error: error, stackTrace: stackTrace);
    }

    exit(0);
  }

  Future<void> _runCleanup() async {
    await _workflowService.unregisterAllHotkeys();
    await hotKeyManager.unregisterAll();
    await _agentSessionService.disconnect();
    await trayManager.destroy();
    await _onBeforeQuit();
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
