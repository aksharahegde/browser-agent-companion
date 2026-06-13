class AgentSession {
  const AgentSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActiveAt,
  });

  static const defaultTitle = 'New chat';

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActiveAt;

  AgentSession copyWith({
    String? title,
    DateTime? updatedAt,
    DateTime? lastActiveAt,
  }) {
    return AgentSession(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}
