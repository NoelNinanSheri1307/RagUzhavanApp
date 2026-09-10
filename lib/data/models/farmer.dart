class Farmer {
  final String id;
  final String name;
  final String phone;
  final String district;
  final String block;
  final String state;
  final String preferredLanguage;
  final List<String> crops;
  final double landSizeAcres;
  final String agroZone;
  final String season;
  final String accountStatus; // 'Active', 'Pending Review', 'Flagged'
  final DateTime lastActivity;

  const Farmer({
    required this.id,
    required this.name,
    required this.phone,
    required this.district,
    this.block = 'Budalur',
    required this.state,
    required this.preferredLanguage,
    required this.crops,
    required this.landSizeAcres,
    required this.agroZone,
    this.season = 'Kuruvai',
    this.accountStatus = 'Active',
    required this.lastActivity,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      district: json['district'] as String? ?? '',
      block: json['block'] as String? ?? 'Budalur',
      state: json['state'] as String? ?? '',
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      crops: (json['crops'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      landSizeAcres: (json['landSizeAcres'] as num?)?.toDouble() ?? 0.0,
      agroZone: json['agroZone'] as String? ?? '',
      season: json['season'] as String? ?? 'Kuruvai',
      accountStatus: json['accountStatus'] as String? ?? 'Active',
      lastActivity: json['lastActivity'] != null
          ? DateTime.parse(json['lastActivity'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'district': district,
      'block': block,
      'state': state,
      'preferredLanguage': preferredLanguage,
      'crops': crops,
      'landSizeAcres': landSizeAcres,
      'agroZone': agroZone,
      'season': season,
      'accountStatus': accountStatus,
      'lastActivity': lastActivity.toIso8601String(),
    };
  }
}
