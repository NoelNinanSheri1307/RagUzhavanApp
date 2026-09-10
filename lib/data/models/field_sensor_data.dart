class FieldSensorData {
  final String sensorId;
  final String district;
  final double soilMoisturePct;
  final double temperatureCelsius;
  final double humidityPct;
  final double nitrogenPpm;
  final double phLevel;
  final DateTime lastUpdated;

  const FieldSensorData({
    required this.sensorId,
    required this.district,
    required this.soilMoisturePct,
    required this.temperatureCelsius,
    required this.humidityPct,
    required this.nitrogenPpm,
    required this.phLevel,
    required this.lastUpdated,
  });

  factory FieldSensorData.fromJson(Map<String, dynamic> json) {
    return FieldSensorData(
      sensorId: json['sensorId'] as String? ?? 'SENS-THANJ-04',
      district: json['district'] as String? ?? 'Thanjavur',
      soilMoisturePct: (json['soilMoisturePct'] as num?)?.toDouble() ?? 42.5,
      temperatureCelsius: (json['temperatureCelsius'] as num?)?.toDouble() ?? 31.2,
      humidityPct: (json['humidityPct'] as num?)?.toDouble() ?? 78.0,
      nitrogenPpm: (json['nitrogenPpm'] as num?)?.toDouble() ?? 145.0,
      phLevel: (json['phLevel'] as num?)?.toDouble() ?? 6.8,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sensorId': sensorId,
      'district': district,
      'soilMoisturePct': soilMoisturePct,
      'temperatureCelsius': temperatureCelsius,
      'humidityPct': humidityPct,
      'nitrogenPpm': nitrogenPpm,
      'phLevel': phLevel,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
