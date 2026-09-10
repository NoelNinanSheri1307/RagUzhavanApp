class Farmer {
  final String id;
  final String name;
  final String phone;
  final String district;
  final String state;
  final String preferredLanguage;
  final List<String> crops;
  final double landSizeAcres;
  final String agroZone;

  const Farmer({
    required this.id,
    required this.name,
    required this.phone,
    required this.district,
    required this.state,
    required this.preferredLanguage,
    required this.crops,
    required this.landSizeAcres,
    required this.agroZone,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      district: json['district'] as String? ?? '',
      state: json['state'] as String? ?? '',
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      crops: (json['crops'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      landSizeAcres: (json['landSizeAcres'] as num?)?.toDouble() ?? 0.0,
      agroZone: json['agroZone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'district': district,
      'state': state,
      'preferredLanguage': preferredLanguage,
      'crops': crops,
      'landSizeAcres': landSizeAcres,
      'agroZone': agroZone,
    };
  }
}
