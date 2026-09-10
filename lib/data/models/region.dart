class Region {
  final String id;
  final String stateName;
  final String districtName;
  final String districtNameTamil;
  final String blockName;
  final String blockNameTamil;
  final String agroClimaticZone;
  final String dominantSoilType;
  final String primarySeason;
  final double latitude;
  final double longitude;
  final bool hasActiveStationData;

  const Region({
    required this.id,
    required this.stateName,
    required this.districtName,
    required this.districtNameTamil,
    required this.blockName,
    required this.blockNameTamil,
    required this.agroClimaticZone,
    required this.dominantSoilType,
    required this.primarySeason,
    required this.latitude,
    required this.longitude,
    this.hasActiveStationData = true,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] as String? ?? '',
      stateName: json['stateName'] as String? ?? 'Tamil Nadu',
      districtName: json['districtName'] as String? ?? '',
      districtNameTamil: json['districtNameTamil'] as String? ?? '',
      blockName: json['blockName'] as String? ?? '',
      blockNameTamil: json['blockNameTamil'] as String? ?? '',
      agroClimaticZone: json['agroClimaticZone'] as String? ?? '',
      dominantSoilType: json['dominantSoilType'] as String? ?? '',
      primarySeason: json['primarySeason'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      hasActiveStationData: json['hasActiveStationData'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stateName': stateName,
      'districtName': districtName,
      'districtNameTamil': districtNameTamil,
      'blockName': blockName,
      'blockNameTamil': blockNameTamil,
      'agroClimaticZone': agroClimaticZone,
      'dominantSoilType': dominantSoilType,
      'primarySeason': primarySeason,
      'latitude': latitude,
      'longitude': longitude,
      'hasActiveStationData': hasActiveStationData,
    };
  }
}
