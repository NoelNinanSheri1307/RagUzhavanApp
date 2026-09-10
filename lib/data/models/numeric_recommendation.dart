class NumericRecommendation {
  final String parameter;
  final double value;
  final String unit;
  final String unitTamil;
  final String ruleId;
  final String sourceTitle;
  final String publicationDate;
  final String retrievedDate;
  final String region;
  final String cropApplicability;

  const NumericRecommendation({
    required this.parameter,
    required this.value,
    required this.unit,
    this.unitTamil = '',
    required this.ruleId,
    required this.sourceTitle,
    required this.publicationDate,
    this.retrievedDate = '2026-09-08',
    this.region = 'Thanjavur Delta',
    this.cropApplicability = 'Paddy / Rice',
  });

  String get label => parameter;
  String get labelTamil => parameter;
  double get numericValue => value;
  String get targetParameter => parameter;
  String get sourceProvenance => sourceTitle;

  factory NumericRecommendation.fromJson(Map<String, dynamic> json) {
    return NumericRecommendation(
      parameter: json['parameter'] as String? ?? json['targetParameter'] as String? ?? json['label'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? (json['numericValue'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      unitTamil: json['unitTamil'] as String? ?? '',
      ruleId: json['ruleId'] as String? ?? '',
      sourceTitle: json['sourceTitle'] as String? ?? json['sourceProvenance'] as String? ?? '',
      publicationDate: json['publicationDate'] as String? ?? '2025-05-10',
      retrievedDate: json['retrievedDate'] as String? ?? '2026-09-08',
      region: json['region'] as String? ?? 'Thanjavur Delta',
      cropApplicability: json['cropApplicability'] as String? ?? 'Paddy / Rice',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parameter': parameter,
      'value': value,
      'unit': unit,
      'unitTamil': unitTamil,
      'ruleId': ruleId,
      'sourceTitle': sourceTitle,
      'publicationDate': publicationDate,
      'retrievedDate': retrievedDate,
      'region': region,
      'cropApplicability': cropApplicability,
      'label': label,
      'numericValue': numericValue,
      'targetParameter': targetParameter,
      'sourceProvenance': sourceProvenance,
    };
  }
}
