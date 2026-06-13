import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../core/app_lifecycle_service.dart';
import '../core/permissions.dart';
import '../data/database/app_database.dart';
import '../data/models/agent_session.dart';
import '../data/models/app_settings.dart';
import '../data/models/workflow.dart';
import '../services/agent/agent_session_service.dart';
import '../services/local/clipboard_service.dart';
import '../services/local/file_service.dart';
import '../services/local/local_tool_executor.dart';
import '../services/local/screenshot_service.dart';
import '../services/security/auth_token_store.dart';
import '../services/security/tool_approval_service.dart';
import '../services/sessions/session_service.dart';
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

final authTokenStoreProvider = Provider<AuthTokenStore>((ref) {
  return SecureAuthTokenStore();
});

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

final toolApprovalServiceProvider = Provider((ref) {
  return ToolApprovalService(
    showWindow: () async {
      ref.read(overlayVisibleProvider.notifier).show();
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setAlwaysOnTop(true);
    },
  );
});

final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService(
    database: ref.watch(databaseProvider),
    agentSessionService: ref.watch(agentSessionServiceProvider),
    readSettings: () => ref.read(settingsProvider),
    updateSettings: (settings) =>
        ref.read(settingsProvider.notifier).update(settings),
  );
});

final sessionsProvider = FutureProvider<List<AgentSession>>((ref) async {
  return ref.watch(sessionServiceProvider).loadSessions();
});

final activeSessionProvider = FutureProvider<AgentSession?>((ref) async {
  ref.watch(settingsProvider);
  return ref.watch(sessionServiceProvider).getActiveSession();
});

final runHistoryProvider = FutureProvider<List<RunHistoryEntry>>((ref) async {
  final settings = ref.watch(settingsProvider);
  if (settings.activeSessionId.isEmpty) return const [];
  final db = ref.watch(databaseProvider);
  return db.loadRunHistory(sessionId: settings.activeSessionId);
});

final workflowServiceProvider = Provider((ref) {
  return WorkflowService(
    database: ref.watch(databaseProvider),
    agentSessionService: ref.watch(agentSessionServiceProvider),
    clipboardService: ref.watch(clipboardServiceProvider),
    screenshotService: ref.watch(screenshotServiceProvider),
    authTokenStore: ref.watch(authTokenStoreProvider),
  );
});

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => AppSettings.defaults;

  Future<void> load() async {
    final database = ref.read(databaseProvider);
    final tokenStore = ref.read(authTokenStoreProvider);
    final dbSettings = await database.loadSettings();
    final token = await migrateLegacyAuthToken(
      legacyToken: dbSettings.authToken,
      store: tokenStore,
    );
    if (dbSettings.authToken.isNotEmpty) {
      await database.saveSettings(dbSettings.copyWith(authToken: ''));
      await database.clearLegacyAuthTokenSetting();
    }
    state = dbSettings.copyWith(authToken: token);
  }

  Future<void> update(AppSettings settings) async {
    await ref.read(authTokenStoreProvider).write(settings.authToken);
    state = settings;
    await ref.read(databaseProvider).saveSettings(
          settings.copyWith(authToken: ''),
        );
    await ref.read(databaseProvider).clearLegacyAuthTokenSetting();
  }
}

class OverlayVisible extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;
  void hide() => state = false;
}

class SettingsVisible extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;
  void hide() => state = false;
}

class WorkflowsVisible extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;
  void hide() => state = false;
}

class SessionsVisible extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;
  void hide() => state = false;
}

final overlayVisibleProvider =
    NotifierProvider<OverlayVisible, bool>(OverlayVisible.new);
final settingsVisibleProvider =
    NotifierProvider<SettingsVisible, bool>(SettingsVisible.new);
final workflowsVisibleProvider =
    NotifierProvider<WorkflowsVisible, bool>(WorkflowsVisible.new);
final sessionsVisibleProvider =
    NotifierProvider<SessionsVisible, bool>(SessionsVisible.new);

final appLifecycleServiceProvider = Provider<AppLifecycleService>((ref) {
  return AppLifecycleService(
    agentSessionService: ref.watch(agentSessionServiceProvider),
    workflowService: ref.watch(workflowServiceProvider),
    onBeforeQuit: () async {
      await ref.read(databaseProvider).close().timeout(
            const Duration(seconds: 1),
            onTimeout: () {},
          );
    },
    hideOverlay: () async {
      ref.read(overlayVisibleProvider.notifier).hide();
      ref.read(settingsVisibleProvider.notifier).hide();
      ref.read(workflowsVisibleProvider.notifier).hide();
      ref.read(sessionsVisibleProvider.notifier).hide();
      await windowManager.hide();
    },
  );
});
