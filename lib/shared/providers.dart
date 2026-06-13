import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_lifecycle_service.dart';
import '../core/permissions.dart';
import '../data/database/app_database.dart';
import '../data/models/app_settings.dart';
import '../services/agent/agent_session_service.dart';
import '../services/local/clipboard_service.dart';
import '../services/local/file_service.dart';
import '../services/local/local_tool_executor.dart';
import '../services/local/screenshot_service.dart';
import '../services/workflows/workflow_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final clipboardServiceProvider = Provider((ref) => ClipboardService());
final screenshotServiceProvider = Provider((ref) => ScreenshotService());
final fileServiceProvider = Provider((ref) => FileService());
final permissionsServiceProvider = Provider((ref) => PermissionsService());

final agentSessionServiceProvider = Provider((ref) {
  final service = AgentSessionService();
  ref.onDispose(service.dispose);
  return service;
});

final localToolExecutorProvider = Provider((ref) {
  return LocalToolExecutor(
    clipboardService: ref.watch(clipboardServiceProvider),
    screenshotService: ref.watch(screenshotServiceProvider),
    fileService: ref.watch(fileServiceProvider),
  );
});

final workflowServiceProvider = Provider((ref) {
  return WorkflowService(
    database: ref.watch(databaseProvider),
    agentSessionService: ref.watch(agentSessionServiceProvider),
    clipboardService: ref.watch(clipboardServiceProvider),
    screenshotService: ref.watch(screenshotServiceProvider),
  );
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.watch(databaseProvider));
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._database) : super(AppSettings.defaults);

  final AppDatabase _database;

  Future<void> load() async {
    state = await _database.loadSettings();
  }

  Future<void> update(AppSettings settings) async {
    state = settings;
    await _database.saveSettings(settings);
  }
}

final appLifecycleServiceProvider = Provider<AppLifecycleService>((ref) {
  return AppLifecycleService(
    agentSessionService: ref.watch(agentSessionServiceProvider),
    workflowService: ref.watch(workflowServiceProvider),
    onBeforeQuit: () async {
      await ref.read(databaseProvider).close();
    },
  );
});

final overlayVisibleProvider = StateProvider<bool>((ref) => false);
final settingsVisibleProvider = StateProvider<bool>((ref) => false);
final workflowsVisibleProvider = StateProvider<bool>((ref) => false);
