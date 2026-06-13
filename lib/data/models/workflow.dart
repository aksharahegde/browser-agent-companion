class WorkflowItem {
  const WorkflowItem({
    required this.id,
    required this.name,
    required this.promptTemplate,
    required this.icon,
    required this.sortOrder,
    required this.attachScreenshot,
    required this.attachClipboard,
    required this.createdAt,
    required this.updatedAt,
    this.hotkey,
  });

  final String id;
  final String name;
  final String promptTemplate;
  final String icon;
  final int sortOrder;
  final bool attachScreenshot;
  final bool attachClipboard;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? hotkey;

  WorkflowItem copyWith({
    String? name,
    String? promptTemplate,
    String? icon,
    int? sortOrder,
    bool? attachScreenshot,
    bool? attachClipboard,
    DateTime? updatedAt,
    String? hotkey,
    bool clearHotkey = false,
  }) {
    return WorkflowItem(
      id: id,
      name: name ?? this.name,
      promptTemplate: promptTemplate ?? this.promptTemplate,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      attachScreenshot: attachScreenshot ?? this.attachScreenshot,
      attachClipboard: attachClipboard ?? this.attachClipboard,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hotkey: clearHotkey ? null : (hotkey ?? this.hotkey),
    );
  }
}

class RunHistoryEntry {
  const RunHistoryEntry({
    required this.id,
    required this.workflowId,
    required this.workflowName,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.summary = '',
    this.prompt = '',
  });

  final String id;
  final String? workflowId;
  final String workflowName;
  final String status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String summary;
  final String prompt;
}
