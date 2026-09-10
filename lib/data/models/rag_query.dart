import 'crop_context.dart';

class RagQuery {
  final String id;
  final String questionText;
  final String language;
  final String regionId;
  final CropContext cropContext;
  final DateTime timestamp;
  final bool isLowBandwidth;

  const RagQuery({
    required this.id,
    required this.questionText,
    required this.language,
    required this.regionId,
    required this.cropContext,
    required this.timestamp,
    this.isLowBandwidth = false,
  });

  factory RagQuery.fromJson(Map<String, dynamic> json) {
    return RagQuery(
      id: json['id'] as String? ?? '',
      questionText: json['questionText'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
      regionId: json['regionId'] as String? ?? 'thanjavur_01',
      cropContext: json['cropContext'] != null
          ? CropContext.fromJson(json['cropContext'] as Map<String, dynamic>)
          : const CropContext(
              cropName: 'Paddy',
              growthStage: 'Tillering',
              irrigationType: 'Canal',
              soilPH: '6.8',
              moistureLevel: 'High',
              season: 'Kuruvai',
            ),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isLowBandwidth: json['isLowBandwidth'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'language': language,
      'regionId': regionId,
      'cropContext': cropContext.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'isLowBandwidth': isLowBandwidth,
    };
  }
}
