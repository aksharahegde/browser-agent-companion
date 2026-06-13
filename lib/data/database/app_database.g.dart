// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_table';
  @override
  VerificationContext validateIntegrity(Insertable<SettingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsTableData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingsTableData extends DataClass
    implements Insertable<SettingsTableData> {
  final String key;
  final String value;
  const SettingsTableData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory SettingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingsTableData copyWith({String? key, String? value}) => SettingsTableData(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  SettingsTableData copyWithCompanion(SettingsTableCompanion data) {
    return SettingsTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsTableData &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsTableData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<SettingsTableData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsTableCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkflowsTable extends Workflows
    with TableInfo<$WorkflowsTable, Workflow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkflowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _promptTemplateMeta =
      const VerificationMeta('promptTemplate');
  @override
  late final GeneratedColumn<String> promptTemplate = GeneratedColumn<String>(
      'prompt_template', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('⚡'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _attachScreenshotMeta =
      const VerificationMeta('attachScreenshot');
  @override
  late final GeneratedColumn<bool> attachScreenshot = GeneratedColumn<bool>(
      'attach_screenshot', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("attach_screenshot" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _attachClipboardMeta =
      const VerificationMeta('attachClipboard');
  @override
  late final GeneratedColumn<bool> attachClipboard = GeneratedColumn<bool>(
      'attach_clipboard', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("attach_clipboard" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        promptTemplate,
        icon,
        sortOrder,
        attachScreenshot,
        attachClipboard,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workflows';
  @override
  VerificationContext validateIntegrity(Insertable<Workflow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('prompt_template')) {
      context.handle(
          _promptTemplateMeta,
          promptTemplate.isAcceptableOrUnknown(
              data['prompt_template']!, _promptTemplateMeta));
    } else if (isInserting) {
      context.missing(_promptTemplateMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('attach_screenshot')) {
      context.handle(
          _attachScreenshotMeta,
          attachScreenshot.isAcceptableOrUnknown(
              data['attach_screenshot']!, _attachScreenshotMeta));
    }
    if (data.containsKey('attach_clipboard')) {
      context.handle(
          _attachClipboardMeta,
          attachClipboard.isAcceptableOrUnknown(
              data['attach_clipboard']!, _attachClipboardMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workflow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workflow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      promptTemplate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}prompt_template'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      attachScreenshot: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}attach_screenshot'])!,
      attachClipboard: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}attach_clipboard'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $WorkflowsTable createAlias(String alias) {
    return $WorkflowsTable(attachedDatabase, alias);
  }
}

class Workflow extends DataClass implements Insertable<Workflow> {
  final String id;
  final String name;
  final String promptTemplate;
  final String icon;
  final int sortOrder;
  final bool attachScreenshot;
  final bool attachClipboard;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Workflow(
      {required this.id,
      required this.name,
      required this.promptTemplate,
      required this.icon,
      required this.sortOrder,
      required this.attachScreenshot,
      required this.attachClipboard,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['prompt_template'] = Variable<String>(promptTemplate);
    map['icon'] = Variable<String>(icon);
    map['sort_order'] = Variable<int>(sortOrder);
    map['attach_screenshot'] = Variable<bool>(attachScreenshot);
    map['attach_clipboard'] = Variable<bool>(attachClipboard);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkflowsCompanion toCompanion(bool nullToAbsent) {
    return WorkflowsCompanion(
      id: Value(id),
      name: Value(name),
      promptTemplate: Value(promptTemplate),
      icon: Value(icon),
      sortOrder: Value(sortOrder),
      attachScreenshot: Value(attachScreenshot),
      attachClipboard: Value(attachClipboard),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Workflow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workflow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      promptTemplate: serializer.fromJson<String>(json['promptTemplate']),
      icon: serializer.fromJson<String>(json['icon']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      attachScreenshot: serializer.fromJson<bool>(json['attachScreenshot']),
      attachClipboard: serializer.fromJson<bool>(json['attachClipboard']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'promptTemplate': serializer.toJson<String>(promptTemplate),
      'icon': serializer.toJson<String>(icon),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'attachScreenshot': serializer.toJson<bool>(attachScreenshot),
      'attachClipboard': serializer.toJson<bool>(attachClipboard),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Workflow copyWith(
          {String? id,
          String? name,
          String? promptTemplate,
          String? icon,
          int? sortOrder,
          bool? attachScreenshot,
          bool? attachClipboard,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Workflow(
        id: id ?? this.id,
        name: name ?? this.name,
        promptTemplate: promptTemplate ?? this.promptTemplate,
        icon: icon ?? this.icon,
        sortOrder: sortOrder ?? this.sortOrder,
        attachScreenshot: attachScreenshot ?? this.attachScreenshot,
        attachClipboard: attachClipboard ?? this.attachClipboard,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Workflow copyWithCompanion(WorkflowsCompanion data) {
    return Workflow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      promptTemplate: data.promptTemplate.present
          ? data.promptTemplate.value
          : this.promptTemplate,
      icon: data.icon.present ? data.icon.value : this.icon,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      attachScreenshot: data.attachScreenshot.present
          ? data.attachScreenshot.value
          : this.attachScreenshot,
      attachClipboard: data.attachClipboard.present
          ? data.attachClipboard.value
          : this.attachClipboard,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workflow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('promptTemplate: $promptTemplate, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('attachScreenshot: $attachScreenshot, ')
          ..write('attachClipboard: $attachClipboard, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, promptTemplate, icon, sortOrder,
      attachScreenshot, attachClipboard, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workflow &&
          other.id == this.id &&
          other.name == this.name &&
          other.promptTemplate == this.promptTemplate &&
          other.icon == this.icon &&
          other.sortOrder == this.sortOrder &&
          other.attachScreenshot == this.attachScreenshot &&
          other.attachClipboard == this.attachClipboard &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WorkflowsCompanion extends UpdateCompanion<Workflow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> promptTemplate;
  final Value<String> icon;
  final Value<int> sortOrder;
  final Value<bool> attachScreenshot;
  final Value<bool> attachClipboard;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WorkflowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.promptTemplate = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.attachScreenshot = const Value.absent(),
    this.attachClipboard = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkflowsCompanion.insert({
    required String id,
    required String name,
    required String promptTemplate,
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.attachScreenshot = const Value.absent(),
    this.attachClipboard = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        promptTemplate = Value(promptTemplate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Workflow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? promptTemplate,
    Expression<String>? icon,
    Expression<int>? sortOrder,
    Expression<bool>? attachScreenshot,
    Expression<bool>? attachClipboard,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (promptTemplate != null) 'prompt_template': promptTemplate,
      if (icon != null) 'icon': icon,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (attachScreenshot != null) 'attach_screenshot': attachScreenshot,
      if (attachClipboard != null) 'attach_clipboard': attachClipboard,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkflowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? promptTemplate,
      Value<String>? icon,
      Value<int>? sortOrder,
      Value<bool>? attachScreenshot,
      Value<bool>? attachClipboard,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return WorkflowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      promptTemplate: promptTemplate ?? this.promptTemplate,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      attachScreenshot: attachScreenshot ?? this.attachScreenshot,
      attachClipboard: attachClipboard ?? this.attachClipboard,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (promptTemplate.present) {
      map['prompt_template'] = Variable<String>(promptTemplate.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (attachScreenshot.present) {
      map['attach_screenshot'] = Variable<bool>(attachScreenshot.value);
    }
    if (attachClipboard.present) {
      map['attach_clipboard'] = Variable<bool>(attachClipboard.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkflowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('promptTemplate: $promptTemplate, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('attachScreenshot: $attachScreenshot, ')
          ..write('attachClipboard: $attachClipboard, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkflowShortcutsTable extends WorkflowShortcuts
    with TableInfo<$WorkflowShortcutsTable, WorkflowShortcut> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkflowShortcutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workflowIdMeta =
      const VerificationMeta('workflowId');
  @override
  late final GeneratedColumn<String> workflowId = GeneratedColumn<String>(
      'workflow_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES workflows (id)'));
  static const VerificationMeta _hotkeyMeta = const VerificationMeta('hotkey');
  @override
  late final GeneratedColumn<String> hotkey = GeneratedColumn<String>(
      'hotkey', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [workflowId, hotkey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workflow_shortcuts';
  @override
  VerificationContext validateIntegrity(Insertable<WorkflowShortcut> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('workflow_id')) {
      context.handle(
          _workflowIdMeta,
          workflowId.isAcceptableOrUnknown(
              data['workflow_id']!, _workflowIdMeta));
    } else if (isInserting) {
      context.missing(_workflowIdMeta);
    }
    if (data.containsKey('hotkey')) {
      context.handle(_hotkeyMeta,
          hotkey.isAcceptableOrUnknown(data['hotkey']!, _hotkeyMeta));
    } else if (isInserting) {
      context.missing(_hotkeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workflowId};
  @override
  WorkflowShortcut map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkflowShortcut(
      workflowId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}workflow_id'])!,
      hotkey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hotkey'])!,
    );
  }

  @override
  $WorkflowShortcutsTable createAlias(String alias) {
    return $WorkflowShortcutsTable(attachedDatabase, alias);
  }
}

class WorkflowShortcut extends DataClass
    implements Insertable<WorkflowShortcut> {
  final String workflowId;
  final String hotkey;
  const WorkflowShortcut({required this.workflowId, required this.hotkey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['workflow_id'] = Variable<String>(workflowId);
    map['hotkey'] = Variable<String>(hotkey);
    return map;
  }

  WorkflowShortcutsCompanion toCompanion(bool nullToAbsent) {
    return WorkflowShortcutsCompanion(
      workflowId: Value(workflowId),
      hotkey: Value(hotkey),
    );
  }

  factory WorkflowShortcut.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkflowShortcut(
      workflowId: serializer.fromJson<String>(json['workflowId']),
      hotkey: serializer.fromJson<String>(json['hotkey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workflowId': serializer.toJson<String>(workflowId),
      'hotkey': serializer.toJson<String>(hotkey),
    };
  }

  WorkflowShortcut copyWith({String? workflowId, String? hotkey}) =>
      WorkflowShortcut(
        workflowId: workflowId ?? this.workflowId,
        hotkey: hotkey ?? this.hotkey,
      );
  WorkflowShortcut copyWithCompanion(WorkflowShortcutsCompanion data) {
    return WorkflowShortcut(
      workflowId:
          data.workflowId.present ? data.workflowId.value : this.workflowId,
      hotkey: data.hotkey.present ? data.hotkey.value : this.hotkey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkflowShortcut(')
          ..write('workflowId: $workflowId, ')
          ..write('hotkey: $hotkey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(workflowId, hotkey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkflowShortcut &&
          other.workflowId == this.workflowId &&
          other.hotkey == this.hotkey);
}

class WorkflowShortcutsCompanion extends UpdateCompanion<WorkflowShortcut> {
  final Value<String> workflowId;
  final Value<String> hotkey;
  final Value<int> rowid;
  const WorkflowShortcutsCompanion({
    this.workflowId = const Value.absent(),
    this.hotkey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkflowShortcutsCompanion.insert({
    required String workflowId,
    required String hotkey,
    this.rowid = const Value.absent(),
  })  : workflowId = Value(workflowId),
        hotkey = Value(hotkey);
  static Insertable<WorkflowShortcut> custom({
    Expression<String>? workflowId,
    Expression<String>? hotkey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workflowId != null) 'workflow_id': workflowId,
      if (hotkey != null) 'hotkey': hotkey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkflowShortcutsCompanion copyWith(
      {Value<String>? workflowId, Value<String>? hotkey, Value<int>? rowid}) {
    return WorkflowShortcutsCompanion(
      workflowId: workflowId ?? this.workflowId,
      hotkey: hotkey ?? this.hotkey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workflowId.present) {
      map['workflow_id'] = Variable<String>(workflowId.value);
    }
    if (hotkey.present) {
      map['hotkey'] = Variable<String>(hotkey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkflowShortcutsCompanion(')
          ..write('workflowId: $workflowId, ')
          ..write('hotkey: $hotkey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RunHistoryTable extends RunHistory
    with TableInfo<$RunHistoryTable, RunHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _workflowIdMeta =
      const VerificationMeta('workflowId');
  @override
  late final GeneratedColumn<String> workflowId = GeneratedColumn<String>(
      'workflow_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _workflowNameMeta =
      const VerificationMeta('workflowName');
  @override
  late final GeneratedColumn<String> workflowName = GeneratedColumn<String>(
      'workflow_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
      'prompt', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        workflowId,
        workflowName,
        status,
        prompt,
        summary,
        startedAt,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'run_history';
  @override
  VerificationContext validateIntegrity(Insertable<RunHistoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workflow_id')) {
      context.handle(
          _workflowIdMeta,
          workflowId.isAcceptableOrUnknown(
              data['workflow_id']!, _workflowIdMeta));
    }
    if (data.containsKey('workflow_name')) {
      context.handle(
          _workflowNameMeta,
          workflowName.isAcceptableOrUnknown(
              data['workflow_name']!, _workflowNameMeta));
    } else if (isInserting) {
      context.missing(_workflowNameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('prompt')) {
      context.handle(_promptMeta,
          prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta));
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RunHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunHistoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      workflowId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}workflow_id']),
      workflowName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}workflow_name'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      prompt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prompt'])!,
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $RunHistoryTable createAlias(String alias) {
    return $RunHistoryTable(attachedDatabase, alias);
  }
}

class RunHistoryData extends DataClass implements Insertable<RunHistoryData> {
  final String id;
  final String? workflowId;
  final String workflowName;
  final String status;
  final String prompt;
  final String summary;
  final DateTime startedAt;
  final DateTime? completedAt;
  const RunHistoryData(
      {required this.id,
      this.workflowId,
      required this.workflowName,
      required this.status,
      required this.prompt,
      required this.summary,
      required this.startedAt,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || workflowId != null) {
      map['workflow_id'] = Variable<String>(workflowId);
    }
    map['workflow_name'] = Variable<String>(workflowName);
    map['status'] = Variable<String>(status);
    map['prompt'] = Variable<String>(prompt);
    map['summary'] = Variable<String>(summary);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  RunHistoryCompanion toCompanion(bool nullToAbsent) {
    return RunHistoryCompanion(
      id: Value(id),
      workflowId: workflowId == null && nullToAbsent
          ? const Value.absent()
          : Value(workflowId),
      workflowName: Value(workflowName),
      status: Value(status),
      prompt: Value(prompt),
      summary: Value(summary),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory RunHistoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunHistoryData(
      id: serializer.fromJson<String>(json['id']),
      workflowId: serializer.fromJson<String?>(json['workflowId']),
      workflowName: serializer.fromJson<String>(json['workflowName']),
      status: serializer.fromJson<String>(json['status']),
      prompt: serializer.fromJson<String>(json['prompt']),
      summary: serializer.fromJson<String>(json['summary']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workflowId': serializer.toJson<String?>(workflowId),
      'workflowName': serializer.toJson<String>(workflowName),
      'status': serializer.toJson<String>(status),
      'prompt': serializer.toJson<String>(prompt),
      'summary': serializer.toJson<String>(summary),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  RunHistoryData copyWith(
          {String? id,
          Value<String?> workflowId = const Value.absent(),
          String? workflowName,
          String? status,
          String? prompt,
          String? summary,
          DateTime? startedAt,
          Value<DateTime?> completedAt = const Value.absent()}) =>
      RunHistoryData(
        id: id ?? this.id,
        workflowId: workflowId.present ? workflowId.value : this.workflowId,
        workflowName: workflowName ?? this.workflowName,
        status: status ?? this.status,
        prompt: prompt ?? this.prompt,
        summary: summary ?? this.summary,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  RunHistoryData copyWithCompanion(RunHistoryCompanion data) {
    return RunHistoryData(
      id: data.id.present ? data.id.value : this.id,
      workflowId:
          data.workflowId.present ? data.workflowId.value : this.workflowId,
      workflowName: data.workflowName.present
          ? data.workflowName.value
          : this.workflowName,
      status: data.status.present ? data.status.value : this.status,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
      summary: data.summary.present ? data.summary.value : this.summary,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunHistoryData(')
          ..write('id: $id, ')
          ..write('workflowId: $workflowId, ')
          ..write('workflowName: $workflowName, ')
          ..write('status: $status, ')
          ..write('prompt: $prompt, ')
          ..write('summary: $summary, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, workflowId, workflowName, status, prompt,
      summary, startedAt, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunHistoryData &&
          other.id == this.id &&
          other.workflowId == this.workflowId &&
          other.workflowName == this.workflowName &&
          other.status == this.status &&
          other.prompt == this.prompt &&
          other.summary == this.summary &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt);
}

class RunHistoryCompanion extends UpdateCompanion<RunHistoryData> {
  final Value<String> id;
  final Value<String?> workflowId;
  final Value<String> workflowName;
  final Value<String> status;
  final Value<String> prompt;
  final Value<String> summary;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const RunHistoryCompanion({
    this.id = const Value.absent(),
    this.workflowId = const Value.absent(),
    this.workflowName = const Value.absent(),
    this.status = const Value.absent(),
    this.prompt = const Value.absent(),
    this.summary = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RunHistoryCompanion.insert({
    required String id,
    this.workflowId = const Value.absent(),
    required String workflowName,
    required String status,
    this.prompt = const Value.absent(),
    this.summary = const Value.absent(),
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        workflowName = Value(workflowName),
        status = Value(status),
        startedAt = Value(startedAt);
  static Insertable<RunHistoryData> custom({
    Expression<String>? id,
    Expression<String>? workflowId,
    Expression<String>? workflowName,
    Expression<String>? status,
    Expression<String>? prompt,
    Expression<String>? summary,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workflowId != null) 'workflow_id': workflowId,
      if (workflowName != null) 'workflow_name': workflowName,
      if (status != null) 'status': status,
      if (prompt != null) 'prompt': prompt,
      if (summary != null) 'summary': summary,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RunHistoryCompanion copyWith(
      {Value<String>? id,
      Value<String?>? workflowId,
      Value<String>? workflowName,
      Value<String>? status,
      Value<String>? prompt,
      Value<String>? summary,
      Value<DateTime>? startedAt,
      Value<DateTime?>? completedAt,
      Value<int>? rowid}) {
    return RunHistoryCompanion(
      id: id ?? this.id,
      workflowId: workflowId ?? this.workflowId,
      workflowName: workflowName ?? this.workflowName,
      status: status ?? this.status,
      prompt: prompt ?? this.prompt,
      summary: summary ?? this.summary,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workflowId.present) {
      map['workflow_id'] = Variable<String>(workflowId.value);
    }
    if (workflowName.present) {
      map['workflow_name'] = Variable<String>(workflowName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunHistoryCompanion(')
          ..write('id: $id, ')
          ..write('workflowId: $workflowId, ')
          ..write('workflowName: $workflowName, ')
          ..write('status: $status, ')
          ..write('prompt: $prompt, ')
          ..write('summary: $summary, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final $WorkflowsTable workflows = $WorkflowsTable(this);
  late final $WorkflowShortcutsTable workflowShortcuts =
      $WorkflowShortcutsTable(this);
  late final $RunHistoryTable runHistory = $RunHistoryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [settingsTable, workflows, workflowShortcuts, runHistory];
}

typedef $$SettingsTableTableCreateCompanionBuilder = SettingsTableCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableTableUpdateCompanionBuilder = SettingsTableCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTableTable,
    SettingsTableData,
    $$SettingsTableTableFilterComposer,
    $$SettingsTableTableOrderingComposer,
    $$SettingsTableTableAnnotationComposer,
    $$SettingsTableTableCreateCompanionBuilder,
    $$SettingsTableTableUpdateCompanionBuilder,
    (
      SettingsTableData,
      BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>
    ),
    SettingsTableData,
    PrefetchHooks Function()> {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsTableCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsTableCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTableTable,
    SettingsTableData,
    $$SettingsTableTableFilterComposer,
    $$SettingsTableTableOrderingComposer,
    $$SettingsTableTableAnnotationComposer,
    $$SettingsTableTableCreateCompanionBuilder,
    $$SettingsTableTableUpdateCompanionBuilder,
    (
      SettingsTableData,
      BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>
    ),
    SettingsTableData,
    PrefetchHooks Function()>;
typedef $$WorkflowsTableCreateCompanionBuilder = WorkflowsCompanion Function({
  required String id,
  required String name,
  required String promptTemplate,
  Value<String> icon,
  Value<int> sortOrder,
  Value<bool> attachScreenshot,
  Value<bool> attachClipboard,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$WorkflowsTableUpdateCompanionBuilder = WorkflowsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> promptTemplate,
  Value<String> icon,
  Value<int> sortOrder,
  Value<bool> attachScreenshot,
  Value<bool> attachClipboard,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$WorkflowsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkflowsTable, Workflow> {
  $$WorkflowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkflowShortcutsTable, List<WorkflowShortcut>>
      _workflowShortcutsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.workflowShortcuts,
              aliasName: 'workflows__id__workflow_shortcuts__workflow_id');

  $$WorkflowShortcutsTableProcessedTableManager get workflowShortcutsRefs {
    final manager = $$WorkflowShortcutsTableTableManager(
            $_db, $_db.workflowShortcuts)
        .filter((f) => f.workflowId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_workflowShortcutsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WorkflowsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkflowsTable> {
  $$WorkflowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get promptTemplate => $composableBuilder(
      column: $table.promptTemplate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get attachScreenshot => $composableBuilder(
      column: $table.attachScreenshot,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get attachClipboard => $composableBuilder(
      column: $table.attachClipboard,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> workflowShortcutsRefs(
      Expression<bool> Function($$WorkflowShortcutsTableFilterComposer f) f) {
    final $$WorkflowShortcutsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workflowShortcuts,
        getReferencedColumn: (t) => t.workflowId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkflowShortcutsTableFilterComposer(
              $db: $db,
              $table: $db.workflowShortcuts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkflowsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkflowsTable> {
  $$WorkflowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get promptTemplate => $composableBuilder(
      column: $table.promptTemplate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get attachScreenshot => $composableBuilder(
      column: $table.attachScreenshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get attachClipboard => $composableBuilder(
      column: $table.attachClipboard,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$WorkflowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkflowsTable> {
  $$WorkflowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get promptTemplate => $composableBuilder(
      column: $table.promptTemplate, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get attachScreenshot => $composableBuilder(
      column: $table.attachScreenshot, builder: (column) => column);

  GeneratedColumn<bool> get attachClipboard => $composableBuilder(
      column: $table.attachClipboard, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> workflowShortcutsRefs<T extends Object>(
      Expression<T> Function($$WorkflowShortcutsTableAnnotationComposer a) f) {
    final $$WorkflowShortcutsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.workflowShortcuts,
            getReferencedColumn: (t) => t.workflowId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$WorkflowShortcutsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.workflowShortcuts,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$WorkflowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkflowsTable,
    Workflow,
    $$WorkflowsTableFilterComposer,
    $$WorkflowsTableOrderingComposer,
    $$WorkflowsTableAnnotationComposer,
    $$WorkflowsTableCreateCompanionBuilder,
    $$WorkflowsTableUpdateCompanionBuilder,
    (Workflow, $$WorkflowsTableReferences),
    Workflow,
    PrefetchHooks Function({bool workflowShortcutsRefs})> {
  $$WorkflowsTableTableManager(_$AppDatabase db, $WorkflowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkflowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkflowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkflowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> promptTemplate = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> attachScreenshot = const Value.absent(),
            Value<bool> attachClipboard = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkflowsCompanion(
            id: id,
            name: name,
            promptTemplate: promptTemplate,
            icon: icon,
            sortOrder: sortOrder,
            attachScreenshot: attachScreenshot,
            attachClipboard: attachClipboard,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String promptTemplate,
            Value<String> icon = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> attachScreenshot = const Value.absent(),
            Value<bool> attachClipboard = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkflowsCompanion.insert(
            id: id,
            name: name,
            promptTemplate: promptTemplate,
            icon: icon,
            sortOrder: sortOrder,
            attachScreenshot: attachScreenshot,
            attachClipboard: attachClipboard,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WorkflowsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workflowShortcutsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workflowShortcutsRefs) db.workflowShortcuts
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workflowShortcutsRefs)
                    await $_getPrefetchedData<Workflow, $WorkflowsTable,
                            WorkflowShortcut>(
                        currentTable: table,
                        referencedTable: $$WorkflowsTableReferences
                            ._workflowShortcutsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkflowsTableReferences(db, table, p0)
                                .workflowShortcutsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workflowId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$WorkflowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkflowsTable,
    Workflow,
    $$WorkflowsTableFilterComposer,
    $$WorkflowsTableOrderingComposer,
    $$WorkflowsTableAnnotationComposer,
    $$WorkflowsTableCreateCompanionBuilder,
    $$WorkflowsTableUpdateCompanionBuilder,
    (Workflow, $$WorkflowsTableReferences),
    Workflow,
    PrefetchHooks Function({bool workflowShortcutsRefs})>;
typedef $$WorkflowShortcutsTableCreateCompanionBuilder
    = WorkflowShortcutsCompanion Function({
  required String workflowId,
  required String hotkey,
  Value<int> rowid,
});
typedef $$WorkflowShortcutsTableUpdateCompanionBuilder
    = WorkflowShortcutsCompanion Function({
  Value<String> workflowId,
  Value<String> hotkey,
  Value<int> rowid,
});

final class $$WorkflowShortcutsTableReferences extends BaseReferences<
    _$AppDatabase, $WorkflowShortcutsTable, WorkflowShortcut> {
  $$WorkflowShortcutsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $WorkflowsTable _workflowIdTable(_$AppDatabase db) => db.workflows
      .createAlias('workflow_shortcuts__workflow_id__workflows__id');

  $$WorkflowsTableProcessedTableManager get workflowId {
    final $_column = $_itemColumn<String>('workflow_id')!;

    final manager = $$WorkflowsTableTableManager($_db, $_db.workflows)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workflowIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WorkflowShortcutsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkflowShortcutsTable> {
  $$WorkflowShortcutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get hotkey => $composableBuilder(
      column: $table.hotkey, builder: (column) => ColumnFilters(column));

  $$WorkflowsTableFilterComposer get workflowId {
    final $$WorkflowsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workflowId,
        referencedTable: $db.workflows,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkflowsTableFilterComposer(
              $db: $db,
              $table: $db.workflows,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkflowShortcutsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkflowShortcutsTable> {
  $$WorkflowShortcutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hotkey => $composableBuilder(
      column: $table.hotkey, builder: (column) => ColumnOrderings(column));

  $$WorkflowsTableOrderingComposer get workflowId {
    final $$WorkflowsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workflowId,
        referencedTable: $db.workflows,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkflowsTableOrderingComposer(
              $db: $db,
              $table: $db.workflows,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkflowShortcutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkflowShortcutsTable> {
  $$WorkflowShortcutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get hotkey =>
      $composableBuilder(column: $table.hotkey, builder: (column) => column);

  $$WorkflowsTableAnnotationComposer get workflowId {
    final $$WorkflowsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workflowId,
        referencedTable: $db.workflows,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkflowsTableAnnotationComposer(
              $db: $db,
              $table: $db.workflows,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkflowShortcutsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkflowShortcutsTable,
    WorkflowShortcut,
    $$WorkflowShortcutsTableFilterComposer,
    $$WorkflowShortcutsTableOrderingComposer,
    $$WorkflowShortcutsTableAnnotationComposer,
    $$WorkflowShortcutsTableCreateCompanionBuilder,
    $$WorkflowShortcutsTableUpdateCompanionBuilder,
    (WorkflowShortcut, $$WorkflowShortcutsTableReferences),
    WorkflowShortcut,
    PrefetchHooks Function({bool workflowId})> {
  $$WorkflowShortcutsTableTableManager(
      _$AppDatabase db, $WorkflowShortcutsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkflowShortcutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkflowShortcutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkflowShortcutsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> workflowId = const Value.absent(),
            Value<String> hotkey = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkflowShortcutsCompanion(
            workflowId: workflowId,
            hotkey: hotkey,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String workflowId,
            required String hotkey,
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkflowShortcutsCompanion.insert(
            workflowId: workflowId,
            hotkey: hotkey,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WorkflowShortcutsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workflowId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (workflowId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workflowId,
                    referencedTable:
                        $$WorkflowShortcutsTableReferences._workflowIdTable(db),
                    referencedColumn: $$WorkflowShortcutsTableReferences
                        ._workflowIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$WorkflowShortcutsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkflowShortcutsTable,
    WorkflowShortcut,
    $$WorkflowShortcutsTableFilterComposer,
    $$WorkflowShortcutsTableOrderingComposer,
    $$WorkflowShortcutsTableAnnotationComposer,
    $$WorkflowShortcutsTableCreateCompanionBuilder,
    $$WorkflowShortcutsTableUpdateCompanionBuilder,
    (WorkflowShortcut, $$WorkflowShortcutsTableReferences),
    WorkflowShortcut,
    PrefetchHooks Function({bool workflowId})>;
typedef $$RunHistoryTableCreateCompanionBuilder = RunHistoryCompanion Function({
  required String id,
  Value<String?> workflowId,
  required String workflowName,
  required String status,
  Value<String> prompt,
  Value<String> summary,
  required DateTime startedAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$RunHistoryTableUpdateCompanionBuilder = RunHistoryCompanion Function({
  Value<String> id,
  Value<String?> workflowId,
  Value<String> workflowName,
  Value<String> status,
  Value<String> prompt,
  Value<String> summary,
  Value<DateTime> startedAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

class $$RunHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $RunHistoryTable> {
  $$RunHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get workflowId => $composableBuilder(
      column: $table.workflowId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get workflowName => $composableBuilder(
      column: $table.workflowName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prompt => $composableBuilder(
      column: $table.prompt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$RunHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $RunHistoryTable> {
  $$RunHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workflowId => $composableBuilder(
      column: $table.workflowId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workflowName => $composableBuilder(
      column: $table.workflowName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prompt => $composableBuilder(
      column: $table.prompt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$RunHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunHistoryTable> {
  $$RunHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workflowId => $composableBuilder(
      column: $table.workflowId, builder: (column) => column);

  GeneratedColumn<String> get workflowName => $composableBuilder(
      column: $table.workflowName, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get prompt =>
      $composableBuilder(column: $table.prompt, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
}

class $$RunHistoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RunHistoryTable,
    RunHistoryData,
    $$RunHistoryTableFilterComposer,
    $$RunHistoryTableOrderingComposer,
    $$RunHistoryTableAnnotationComposer,
    $$RunHistoryTableCreateCompanionBuilder,
    $$RunHistoryTableUpdateCompanionBuilder,
    (
      RunHistoryData,
      BaseReferences<_$AppDatabase, $RunHistoryTable, RunHistoryData>
    ),
    RunHistoryData,
    PrefetchHooks Function()> {
  $$RunHistoryTableTableManager(_$AppDatabase db, $RunHistoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> workflowId = const Value.absent(),
            Value<String> workflowName = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> prompt = const Value.absent(),
            Value<String> summary = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RunHistoryCompanion(
            id: id,
            workflowId: workflowId,
            workflowName: workflowName,
            status: status,
            prompt: prompt,
            summary: summary,
            startedAt: startedAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> workflowId = const Value.absent(),
            required String workflowName,
            required String status,
            Value<String> prompt = const Value.absent(),
            Value<String> summary = const Value.absent(),
            required DateTime startedAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RunHistoryCompanion.insert(
            id: id,
            workflowId: workflowId,
            workflowName: workflowName,
            status: status,
            prompt: prompt,
            summary: summary,
            startedAt: startedAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RunHistoryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RunHistoryTable,
    RunHistoryData,
    $$RunHistoryTableFilterComposer,
    $$RunHistoryTableOrderingComposer,
    $$RunHistoryTableAnnotationComposer,
    $$RunHistoryTableCreateCompanionBuilder,
    $$RunHistoryTableUpdateCompanionBuilder,
    (
      RunHistoryData,
      BaseReferences<_$AppDatabase, $RunHistoryTable, RunHistoryData>
    ),
    RunHistoryData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
  $$WorkflowsTableTableManager get workflows =>
      $$WorkflowsTableTableManager(_db, _db.workflows);
  $$WorkflowShortcutsTableTableManager get workflowShortcuts =>
      $$WorkflowShortcutsTableTableManager(_db, _db.workflowShortcuts);
  $$RunHistoryTableTableManager get runHistory =>
      $$RunHistoryTableTableManager(_db, _db.runHistory);
}
