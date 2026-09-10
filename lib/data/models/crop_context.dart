class CropContext {
  final String cropName;
  final String growthStage;
  final String irrigationType;
  final String soilPH;
  final String moistureLevel;
  final String season;

  const CropContext({
    required this.cropName,
    required this.growthStage,
    required this.irrigationType,
    required this.soilPH,
    required this.moistureLevel,
    required this.season,
  });

  factory CropContext.fromJson(Map<String, dynamic> json) {
    return CropContext(
      cropName: json['cropName'] as String? ?? 'Paddy / Rice',
      growthStage: json['growthStage'] as String? ?? 'Tillering',
      irrigationType: json['irrigationType'] as String? ?? 'Canal / Canal-fed',
      soilPH: json['soilPH'] as String? ?? '6.8 Neutral',
      moistureLevel: json['moistureLevel'] as String? ?? 'Adequate',
      season: json['season'] as String? ?? 'Kuruvai',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cropName': cropName,
      'growthStage': growthStage,
      'irrigationType': irrigationType,
      'soilPH': soilPH,
      'moistureLevel': moistureLevel,
      'season': season,
    };
  }
}
