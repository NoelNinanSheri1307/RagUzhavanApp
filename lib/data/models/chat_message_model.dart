import 'dart:convert';

class ChatMessageModel {
  final int id;
  final String role;
  final String content;
  final String? reasoning;
  final List<dynamic>? sources;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.role,
    required this.content,
    this.reasoning,
    this.sources,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    List<dynamic>? parsedSources;
    if (json['sources'] != null) {
      if (json['sources'] is List) {
        parsedSources = json['sources'] as List<dynamic>;
      } else if (json['sources'] is String) {
        try {
          parsedSources = jsonDecode(json['sources'] as String) as List<dynamic>;
        } catch (_) {}
      }
    }

    return ChatMessageModel(
      id: json['id'] as int? ?? 0,
      role: json['role'] as String? ?? 'assistant',
      content: json['content'] as String? ?? '',
      reasoning: json['reasoning'] as String?,
      sources: parsedSources,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'reasoning': reasoning,
      'sources': sources,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
