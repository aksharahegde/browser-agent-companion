import 'package:drift/drift.dart';

class SettingsTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class Workflows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get promptTemplate => text()();
  TextColumn get icon => text().withDefault(const Constant('⚡'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get attachScreenshot =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get attachClipboard =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class WorkflowShortcuts extends Table {
  TextColumn get workflowId => text().references(Workflows, #id)();
  TextColumn get hotkey => text()();

  @override
  Set<Column> get primaryKey => {workflowId};
}

class ChatSessions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant('New chat'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastActiveAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class RunHistory extends Table {
  TextColumn get id => text()();
  TextColumn get workflowId => text().nullable()();
  TextColumn get sessionId => text().nullable()();
  TextColumn get workflowName => text()();
  TextColumn get status => text()();
  TextColumn get prompt => text().withDefault(const Constant(''))();
  TextColumn get summary => text().withDefault(const Constant(''))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
