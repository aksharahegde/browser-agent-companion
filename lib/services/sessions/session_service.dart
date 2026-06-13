import 'package:uuid/uuid.dart';

import '../../data/database/app_database.dart';
import '../../data/models/agent_session.dart';
import '../../data/models/app_settings.dart';
import '../agent/agent_session_service.dart';

class SessionService {
  SessionService({
    required AppDatabase database,
    required AgentSessionService agentSessionService,
    required Future<void> Function(AppSettings) updateSettings,
    required AppSettings Function() readSettings,
  })  : _database = database,
        _agentSessionService = agentSessionService,
        _updateSettings = updateSettings,
        _readSettings = readSettings;

  final AppDatabase _database;
  final AgentSessionService _agentSessionService;
  final Future<void> Function(AppSettings) _updateSettings;
  final AppSettings Function() _readSettings;
  final _uuid = const Uuid();

  Future<void> ensureInitialized() async {
    final settings = _readSettings();
    await _database.migrateLegacySessionIfNeeded(settings.activeSessionId);

    final sessions = await _database.loadSessions();
    if (sessions.isEmpty) {
      final session = await createSession();
      await switchActiveSession(session.id);
      return;
    }

    if (settings.activeSessionId.isEmpty ||
        !sessions.any((s) => s.id == settings.activeSessionId)) {
      await switchActiveSession(sessions.first.id);
    }
  }

  Future<List<AgentSession>> loadSessions() => _database.loadSessions();

  Future<AgentSession?> getActiveSession() async {
    final settings = _readSettings();
    if (settings.activeSessionId.isEmpty) return null;
    return _database.getSession(settings.activeSessionId);
  }

  Future<AgentSession> createSession() async {
    final now = DateTime.now();
    final session = AgentSession(
      id: _uuid.v4(),
      title: AgentSession.defaultTitle,
      createdAt: now,
      updatedAt: now,
      lastActiveAt: now,
    );
    await _database.upsertSession(session);
    return session;
  }

  Future<AgentSession> renameSession(String id, String title) async {
    final existing = await _database.getSession(id);
    if (existing == null) {
      throw StateError('Session not found');
    }
    final trimmed = title.trim();
    final updated = existing.copyWith(
      title: trimmed.isEmpty ? AgentSession.defaultTitle : trimmed,
      updatedAt: DateTime.now(),
    );
    await _database.upsertSession(updated);
    return updated;
  }

  Future<void> deleteSession(String id) async {
    final settings = _readSettings();
    await _database.deleteSession(id);

    if (settings.activeSessionId != id) return;

    final remaining = await _database.loadSessions();
    if (remaining.isEmpty) {
      final created = await createSession();
      await switchActiveSession(created.id);
      return;
    }

    await switchActiveSession(remaining.first.id);
  }

  Future<AgentSession> switchActiveSession(String id) async {
    final session = await _database.getSession(id);
    if (session == null) {
      throw StateError('Session not found');
    }

    final settings = _readSettings();
    final updatedSettings = settings.copyWith(activeSessionId: id);
    await _updateSettings(updatedSettings);
    await _database.touchSession(id);
    await _agentSessionService.configure(updatedSettings);
    return session;
  }

  Future<AgentSession> createAndSwitchSession() async {
    final session = await createSession();
    await switchActiveSession(session.id);
    return session;
  }

  Future<void> maybeAutoTitle(String sessionId, String firstPrompt) async {
    final session = await _database.getSession(sessionId);
    if (session == null) return;
    if (session.title != AgentSession.defaultTitle) return;

    final trimmed = firstPrompt.trim();
    if (trimmed.isEmpty) return;

    const maxLen = 48;
    final title = trimmed.length <= maxLen
        ? trimmed
        : '${trimmed.substring(0, maxLen - 1)}…';
    await _database.touchSession(sessionId, title: title);
  }

  Future<void> touchActiveSession() async {
    final settings = _readSettings();
    if (settings.activeSessionId.isEmpty) return;
    await _database.touchSession(settings.activeSessionId);
  }
}
