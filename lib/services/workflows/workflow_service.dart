import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:uuid/uuid.dart';

import '../../data/database/app_database.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/trace_event.dart';
import '../../data/models/workflow.dart';
import '../agent/agent_session_service.dart';
import '../local/clipboard_service.dart';
import '../local/screenshot_service.dart';

class WorkflowService {
  WorkflowService({
    required AppDatabase database,
    required AgentSessionService agentSessionService,
    required ClipboardService clipboardService,
    required ScreenshotService screenshotService,
  })  : _database = database,
        _agentSessionService = agentSessionService,
        _clipboardService = clipboardService,
        _screenshotService = screenshotService;

  final AppDatabase _database;
  final AgentSessionService _agentSessionService;
  final ClipboardService _clipboardService;
  final ScreenshotService _screenshotService;
  final _uuid = const Uuid();
  final _registeredHotkeys = <String, HotKey>{};

  Future<List<WorkflowItem>> loadWorkflows() => _database.loadWorkflows();

  Future<void> seedDefaultsIfEmpty() async {
    final existing = await _database.loadWorkflows();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    final defaults = [
      WorkflowItem(
        id: _uuid.v4(),
        name: 'Research this topic',
        promptTemplate:
            'Research the following topic using the browser and summarize key findings:\n\n{{clipboard}}',
        icon: '🔍',
        sortOrder: 0,
        attachScreenshot: false,
        attachClipboard: true,
        createdAt: now,
        updatedAt: now,
      ),
      WorkflowItem(
        id: _uuid.v4(),
        name: 'Check GitHub notifications',
        promptTemplate:
            'Open GitHub and check my notifications. Summarize anything that needs my attention.',
        icon: '🐙',
        sortOrder: 1,
        attachScreenshot: false,
        attachClipboard: false,
        createdAt: now,
        updatedAt: now,
      ),
      WorkflowItem(
        id: _uuid.v4(),
        name: 'Summarize latest PRs',
        promptTemplate:
            'Find my most recent open pull requests and summarize their status, review comments, and CI results.',
        icon: '📋',
        sortOrder: 2,
        attachScreenshot: true,
        attachClipboard: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final workflow in defaults) {
      await _database.upsertWorkflow(workflow);
    }
  }

  Future<void> saveWorkflow(WorkflowItem workflow) async {
    await _database.upsertWorkflow(workflow);
    await _registerHotkey(workflow);
  }

  Future<void> deleteWorkflow(String id) async {
    final hotkey = _registeredHotkeys.remove(id);
    if (hotkey != null) {
      await hotKeyManager.unregister(hotkey);
    }
    await _database.deleteWorkflow(id);
  }

  Future<void> registerAllHotkeys() async {
    final workflows = await _database.loadWorkflows();
    for (final workflow in workflows) {
      await _registerHotkey(workflow);
    }
  }

  Future<void> unregisterAllHotkeys() async {
    for (final hotkey in _registeredHotkeys.values) {
      await hotKeyManager.unregister(hotkey);
    }
    _registeredHotkeys.clear();
  }

  Future<void> runWorkflow(
    WorkflowItem workflow, {
    String? overridePrompt,
    AppSettings? settings,
  }) async {
    final prompt = await _resolvePrompt(
      overridePrompt ?? workflow.promptTemplate,
    );
    final context = await _buildContext(workflow, settings);
    final runId = _uuid.v4();

    await _database.insertRunHistory(
      RunHistoryEntry(
        id: runId,
        workflowId: workflow.id,
        workflowName: workflow.name,
        status: RunStatus.running.name,
        startedAt: DateTime.now(),
        prompt: prompt,
      ),
    );

    try {
      await _agentSessionService.runWorkflow(prompt, context);
      await _database.insertRunHistory(
        RunHistoryEntry(
          id: runId,
          workflowId: workflow.id,
          workflowName: workflow.name,
          status: RunStatus.completed.name,
          startedAt: DateTime.now(),
          completedAt: DateTime.now(),
          prompt: prompt,
          summary: 'Completed',
        ),
      );
    } catch (error) {
      await _database.insertRunHistory(
        RunHistoryEntry(
          id: runId,
          workflowId: workflow.id,
          workflowName: workflow.name,
          status: RunStatus.failed.name,
          startedAt: DateTime.now(),
          completedAt: DateTime.now(),
          prompt: prompt,
          summary: error.toString(),
        ),
      );
      rethrow;
    }
  }

  Future<String> _resolvePrompt(String template) async {
    var result = template;
    if (result.contains('{{clipboard}}')) {
      final text = await _clipboardService.readText() ?? '';
      result = result.replaceAll('{{clipboard}}', text);
    }
    return result;
  }

  Future<AgentRunContext> _buildContext(
    WorkflowItem workflow,
    AppSettings? settings,
  ) async {
    String? clipboardText;
    String? screenshotBase64;

    final attachClipboard =
        workflow.attachClipboard || settings?.defaultAttachClipboard == true;
    final attachScreenshot =
        workflow.attachScreenshot || settings?.defaultAttachScreenshot == true;

    if (attachClipboard) {
      clipboardText = await _clipboardService.readText();
    }
    if (attachScreenshot) {
      final shot = await _screenshotService.captureScreen();
      screenshotBase64 = shot?.base64;
    }

    return AgentRunContext(
      clipboardText: clipboardText,
      screenshotBase64: screenshotBase64,
    );
  }

  Future<void> _registerHotkey(WorkflowItem workflow) async {
    final existing = _registeredHotkeys.remove(workflow.id);
    if (existing != null) {
      await hotKeyManager.unregister(existing);
    }

    final combo = workflow.hotkey;
    if (combo == null || combo.isEmpty) return;

    final hotkey = _parseHotkey(combo);
    if (hotkey == null) return;

    _registeredHotkeys[workflow.id] = hotkey;
    await hotKeyManager.register(
      hotkey,
      keyDownHandler: (_) => runWorkflow(workflow),
    );
  }

  HotKey? _parseHotkey(String combo) {
    final parts = combo.toLowerCase().split('+').map((p) => p.trim()).toList();
    final modifiers = <HotKeyModifier>[];
    PhysicalKeyboardKey? key;

    for (final part in parts) {
      switch (part) {
        case 'cmd':
        case 'meta':
          modifiers.add(HotKeyModifier.meta);
        case 'ctrl':
        case 'control':
          modifiers.add(HotKeyModifier.control);
        case 'alt':
        case 'option':
          modifiers.add(HotKeyModifier.alt);
        case 'shift':
          modifiers.add(HotKeyModifier.shift);
        default:
          key = _keyFromChar(part);
      }
    }

    if (key == null) return null;
    return HotKey(key: key, modifiers: modifiers, scope: HotKeyScope.system);
  }

  PhysicalKeyboardKey? _keyFromChar(String value) {
    final keyMap = <String, PhysicalKeyboardKey>{
      '1': PhysicalKeyboardKey.digit1,
      '2': PhysicalKeyboardKey.digit2,
      '3': PhysicalKeyboardKey.digit3,
      '4': PhysicalKeyboardKey.digit4,
      '5': PhysicalKeyboardKey.digit5,
      '6': PhysicalKeyboardKey.digit6,
      '7': PhysicalKeyboardKey.digit7,
      '8': PhysicalKeyboardKey.digit8,
      '9': PhysicalKeyboardKey.digit9,
      '0': PhysicalKeyboardKey.digit0,
      'a': PhysicalKeyboardKey.keyA,
      'b': PhysicalKeyboardKey.keyB,
      'c': PhysicalKeyboardKey.keyC,
      'd': PhysicalKeyboardKey.keyD,
      'e': PhysicalKeyboardKey.keyE,
      'f': PhysicalKeyboardKey.keyF,
      'g': PhysicalKeyboardKey.keyG,
      'h': PhysicalKeyboardKey.keyH,
      'i': PhysicalKeyboardKey.keyI,
      'j': PhysicalKeyboardKey.keyJ,
      'k': PhysicalKeyboardKey.keyK,
      'l': PhysicalKeyboardKey.keyL,
      'm': PhysicalKeyboardKey.keyM,
      'n': PhysicalKeyboardKey.keyN,
      'o': PhysicalKeyboardKey.keyO,
      'p': PhysicalKeyboardKey.keyP,
      'q': PhysicalKeyboardKey.keyQ,
      'r': PhysicalKeyboardKey.keyR,
      's': PhysicalKeyboardKey.keyS,
      't': PhysicalKeyboardKey.keyT,
      'u': PhysicalKeyboardKey.keyU,
      'v': PhysicalKeyboardKey.keyV,
      'w': PhysicalKeyboardKey.keyW,
      'x': PhysicalKeyboardKey.keyX,
      'y': PhysicalKeyboardKey.keyY,
      'z': PhysicalKeyboardKey.keyZ,
    };
    return keyMap[value.toLowerCase()];
  }
}
