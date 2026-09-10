class FieldSensorData {
  final String sensorId;
  final String district;
  final double soilMoisturePct;
  final double temperatureCelsius;
  final double humidityPct;
  final double nitrogenPpm;
  final double phLevel;
  final double waterLevel; // water level in cm
  final double ambientLight; // lux
  final DateTime lastUpdated;
  final bool isDemoData; // Flag indicating mock/demo telemetry

  const FieldSensorData({
    required this.sensorId,
    required this.district,
    required this.soilMoisturePct,
    required this.temperatureCelsius,
    required this.humidityPct,
    required this.nitrogenPpm,
    required this.phLevel,
    this.waterLevel = 5.2,
    this.ambientLight = 32000.0,
    required this.lastUpdated,
    this.isDemoData = true,
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
      waterLevel: (json['waterLevel'] as num?)?.toDouble() ?? 5.2,
      ambientLight: (json['ambientLight'] as num?)?.toDouble() ?? 32000.0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
      isDemoData: json['isDemoData'] as bool? ?? true,
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
      'waterLevel': waterLevel,
      'ambientLight': ambientLight,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isDemoData': isDemoData,
    };
  }
}
