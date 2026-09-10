class KnowledgeSourceModel {
  final int id;
  final String sourceType;
  final String title;
  final String origin;
  final String ref;
  final int chunkCount;
  final DateTime? createdAt;

  const KnowledgeSourceModel({
    required this.id,
    required this.sourceType,
    required this.title,
    required this.origin,
    required this.ref,
    required this.chunkCount,
    this.createdAt,
  });

  factory KnowledgeSourceModel.fromJson(Map<String, dynamic> json) {
    return KnowledgeSourceModel(
      id: json['id'] as int? ?? 0,
      sourceType: json['source_type'] as String? ?? 'doc',
      title: json['title'] as String? ?? 'Untitled Source',
      origin: json['origin'] as String? ?? 'file',
      ref: json['ref'] as String? ?? '',
      chunkCount: json['chunk_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source_type': sourceType,
      'title': title,
      'origin': origin,
      'ref': ref,
      'chunk_count': chunkCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
