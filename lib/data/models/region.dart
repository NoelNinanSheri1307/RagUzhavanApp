class Region {
  final String id;
  final String districtName;
  final String districtNameTamil;
  final String stateName;
  final String agroClimaticZone;
  final String dominantSoilType;
  final String primarySeason;
  final double latitude;
  final double longitude;

  const Region({
    required this.id,
    required this.districtName,
    required this.districtNameTamil,
    required this.stateName,
    required this.agroClimaticZone,
    required this.dominantSoilType,
    required this.primarySeason,
    required this.latitude,
    required this.longitude,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] as String? ?? '',
      districtName: json['districtName'] as String? ?? '',
      districtNameTamil: json['districtNameTamil'] as String? ?? '',
      stateName: json['stateName'] as String? ?? '',
      agroClimaticZone: json['agroClimaticZone'] as String? ?? '',
      dominantSoilType: json['dominantSoilType'] as String? ?? '',
      primarySeason: json['primarySeason'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'districtName': districtName,
      'districtNameTamil': districtNameTamil,
      'stateName': stateName,
      'agroClimaticZone': agroClimaticZone,
      'dominantSoilType': dominantSoilType,
      'primarySeason': primarySeason,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
