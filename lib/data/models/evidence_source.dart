class EvidenceSource {
  final String id;
  final String title;
  final String publicationDate;
  final String authorOrInstitute;
  final String documentType;
  final String excerpt;
  final String excerptTamil;
  final double confidenceScore;
  final int datasetAgeDays;
  final String urlOrRef;
  final bool isVerified;

  const EvidenceSource({
    required this.id,
    required this.title,
    required this.publicationDate,
    required this.authorOrInstitute,
    required this.documentType,
    required this.excerpt,
    required this.excerptTamil,
    required this.confidenceScore,
    required this.datasetAgeDays,
    required this.urlOrRef,
    this.isVerified = true,
  });

  factory EvidenceSource.fromJson(Map<String, dynamic> json) {
    return EvidenceSource(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      publicationDate: json['publicationDate'] as String? ?? '',
      authorOrInstitute: json['authorOrInstitute'] as String? ?? '',
      documentType: json['documentType'] as String? ?? 'Research Bulletin',
      excerpt: json['excerpt'] as String? ?? '',
      excerptTamil: json['excerptTamil'] as String? ?? '',
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.9,
      datasetAgeDays: (json['datasetAgeDays'] as num?)?.toInt() ?? 14,
      urlOrRef: json['urlOrRef'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'publicationDate': publicationDate,
      'authorOrInstitute': authorOrInstitute,
      'documentType': documentType,
      'excerpt': excerpt,
      'excerptTamil': excerptTamil,
      'confidenceScore': confidenceScore,
      'datasetAgeDays': datasetAgeDays,
      'urlOrRef': urlOrRef,
      'isVerified': isVerified,
    };
  }
}
