import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/agent_session.dart';
import '../models/app_settings.dart';
import '../models/workflow.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [SettingsTable, Workflows, WorkflowShortcuts, ChatSessions, RunHistory],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(chatSessions);
            await m.addColumn(runHistory, runHistory.sessionId);
          }
        },
      );

  Future<void> saveSetting(String key, String value) async {
    await into(settingsTable).insertOnConflictUpdate(
      SettingsTableCompanion.insert(key: key, value: value),
    );
  }

  Future<String?> getSetting(String key) async {
    final row =
        await (select(settingsTable)..where((t) => t.key.equals(key)))
            .getSingleOrNull();
    return row?.value;
  }

  Future<AppSettings> loadSettings() async {
    final rows = await select(settingsTable).get();
    final map = {for (final row in rows) row.key: row.value};

    return AppSettings(
      agentHost: map['agentHost'] ?? AppSettings.defaults.agentHost,
      activeSessionId:
          map['activeSessionId'] ?? map['sessionId'] ?? '',
      authToken: map['authToken'] ?? '',
      overlayOpacity: double.tryParse(map['overlayOpacity'] ?? '') ?? 0.95,
      overlayFontSize: double.tryParse(map['overlayFontSize'] ?? '') ?? 13.0,
      launchAtLogin: map['launchAtLogin'] == 'true',
      defaultAttachScreenshot: map['defaultAttachScreenshot'] == 'true',
      defaultAttachClipboard: map['defaultAttachClipboard'] != 'false',
      overlayX: double.tryParse(map['overlayX'] ?? ''),
      overlayY: double.tryParse(map['overlayY'] ?? ''),
      overlayWidth: double.tryParse(map['overlayWidth'] ?? ''),
      overlayHeight: double.tryParse(map['overlayHeight'] ?? ''),
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final entries = <String, String>{
      'agentHost': settings.agentHost,
      'activeSessionId': settings.activeSessionId,
      'authToken': settings.authToken,
      'overlayOpacity': settings.overlayOpacity.toString(),
      'overlayFontSize': settings.overlayFontSize.toString(),
      'launchAtLogin': settings.launchAtLogin.toString(),
      'defaultAttachScreenshot': settings.defaultAttachScreenshot.toString(),
      'defaultAttachClipboard': settings.defaultAttachClipboard.toString(),
      if (settings.overlayX != null) 'overlayX': settings.overlayX!.toString(),
      if (settings.overlayY != null) 'overlayY': settings.overlayY!.toString(),
      if (settings.overlayWidth != null)
        'overlayWidth': settings.overlayWidth!.toString(),
      if (settings.overlayHeight != null)
        'overlayHeight': settings.overlayHeight!.toString(),
    };

    await batch((batch) {
      for (final entry in entries.entries) {
        batch.insert(
          settingsTable,
          SettingsTableCompanion.insert(key: entry.key, value: entry.value),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<List<AgentSession>> loadSessions() async {
    final rows = await (select(chatSessions)
          ..orderBy([(t) => OrderingTerm.desc(t.lastActiveAt)]))
        .get();

    return rows.map(_mapSessionRow).toList();
  }

  Future<AgentSession?> getSession(String id) async {
    final row = await (select(chatSessions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _mapSessionRow(row);
  }

  Future<void> upsertSession(AgentSession session) async {
    await into(chatSessions).insertOnConflictUpdate(
      ChatSessionsCompanion(
        id: Value(session.id),
        title: Value(session.title),
        createdAt: Value(session.createdAt),
        updatedAt: Value(session.updatedAt),
        lastActiveAt: Value(session.lastActiveAt),
      ),
    );
  }

  Future<void> deleteSession(String id) async {
    await (delete(chatSessions)..where((t) => t.id.equals(id))).go();
  }

  Future<void> touchSession(String id, {String? title}) async {
    final existing = await getSession(id);
    if (existing == null) return;
    final now = DateTime.now();
    await upsertSession(
      existing.copyWith(
        title: title ?? existing.title,
        updatedAt: now,
        lastActiveAt: now,
      ),
    );
  }

  Future<void> migrateLegacySessionIfNeeded(String legacySessionId) async {
    final existing = await loadSessions();
    if (existing.isNotEmpty) return;

    final id = legacySessionId.isNotEmpty ? legacySessionId : '';
    if (id.isEmpty) return;

    final now = DateTime.now();
    await upsertSession(
      AgentSession(
        id: id,
        title: AgentSession.defaultTitle,
        createdAt: now,
        updatedAt: now,
        lastActiveAt: now,
      ),
    );
  }

  AgentSession _mapSessionRow(ChatSession row) {
    return AgentSession(
      id: row.id,
      title: row.title,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      lastActiveAt: row.lastActiveAt,
    );
  }

  Future<List<WorkflowItem>> loadWorkflows() async {
    final workflowRows = await (select(workflows)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    final shortcutRows = await select(workflowShortcuts).get();
    final shortcutMap = {
      for (final row in shortcutRows) row.workflowId: row.hotkey,
    };

    return workflowRows
        .map(
          (row) => WorkflowItem(
            id: row.id,
            name: row.name,
            promptTemplate: row.promptTemplate,
            icon: row.icon,
            sortOrder: row.sortOrder,
            attachScreenshot: row.attachScreenshot,
            attachClipboard: row.attachClipboard,
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
            hotkey: shortcutMap[row.id],
          ),
        )
        .toList();
  }

  Future<void> upsertWorkflow(WorkflowItem workflow) async {
    await into(workflows).insertOnConflictUpdate(
      WorkflowsCompanion(
        id: Value(workflow.id),
        name: Value(workflow.name),
        promptTemplate: Value(workflow.promptTemplate),
        icon: Value(workflow.icon),
        sortOrder: Value(workflow.sortOrder),
        attachScreenshot: Value(workflow.attachScreenshot),
        attachClipboard: Value(workflow.attachClipboard),
        createdAt: Value(workflow.createdAt),
        updatedAt: Value(workflow.updatedAt),
      ),
    );

    if (workflow.hotkey != null && workflow.hotkey!.isNotEmpty) {
      await into(workflowShortcuts).insertOnConflictUpdate(
        WorkflowShortcutsCompanion.insert(
          workflowId: workflow.id,
          hotkey: workflow.hotkey!,
        ),
      );
    } else {
      await (delete(workflowShortcuts)
            ..where((t) => t.workflowId.equals(workflow.id)))
          .go();
    }
  }

  Future<void> deleteWorkflow(String id) async {
    await (delete(workflowShortcuts)..where((t) => t.workflowId.equals(id)))
        .go();
    await (delete(workflows)..where((t) => t.id.equals(id))).go();
  }

  Future<void> insertRunHistory(RunHistoryEntry entry) async {
    await into(runHistory).insertOnConflictUpdate(
      RunHistoryCompanion(
        id: Value(entry.id),
        workflowId: Value(entry.workflowId),
        sessionId: Value(entry.sessionId),
        workflowName: Value(entry.workflowName),
        status: Value(entry.status),
        prompt: Value(entry.prompt),
        summary: Value(entry.summary),
        startedAt: Value(entry.startedAt),
        completedAt: Value(entry.completedAt),
      ),
    );
  }

  Future<List<RunHistoryEntry>> loadRunHistory({
    required String sessionId,
    int limit = 50,
  }) async {
    final rows = await (select(runHistory)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(limit))
        .get();

    return rows
        .map(
          (row) => RunHistoryEntry(
            id: row.id,
            workflowId: row.workflowId,
            sessionId: row.sessionId,
            workflowName: row.workflowName,
            status: row.status,
            prompt: row.prompt,
            summary: row.summary,
            startedAt: row.startedAt,
            completedAt: row.completedAt,
          ),
        )
        .toList();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'cua_companion.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
