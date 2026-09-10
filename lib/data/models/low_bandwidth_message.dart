class LowBandwidthMessage {
  final String id;
  final String queryText;
  final int payloadSizeBytes; // e.g. 1840 bytes = 1.8 KB
  final int maxConstraintBytes; // 51200 bytes = 50 KB
  final String recommendation;
  final String recommendationTamil;
  final String essentialReason;
  final String essentialReasonTamil;
  final String citedSource;
  final String publicationDate;
  final int dataAgeDays;
  final String queueStatus;
  final DateTime timestamp;

  const LowBandwidthMessage({
    required this.id,
    required this.queryText,
    required this.payloadSizeBytes,
    this.maxConstraintBytes = 51200,
    required this.recommendation,
    required this.recommendationTamil,
    required this.essentialReason,
    required this.essentialReasonTamil,
    required this.citedSource,
    required this.publicationDate,
    required this.dataAgeDays,
    required this.queueStatus,
    required this.timestamp,
  });

  double get payloadSizeKb => payloadSizeBytes / 1024.0;
  double get maxConstraintKb => maxConstraintBytes / 1024.0;

  factory LowBandwidthMessage.fromJson(Map<String, dynamic> json) {
    return LowBandwidthMessage(
      id: json['id'] as String? ?? '',
      queryText: json['queryText'] as String? ?? '',
      payloadSizeBytes: (json['payloadSizeBytes'] as num?)?.toInt() ?? 1840,
      maxConstraintBytes: (json['maxConstraintBytes'] as num?)?.toInt() ?? 51200,
      recommendation: json['recommendation'] as String? ?? '',
      recommendationTamil: json['recommendationTamil'] as String? ?? '',
      essentialReason: json['essentialReason'] as String? ?? '',
      essentialReasonTamil: json['essentialReasonTamil'] as String? ?? '',
      citedSource: json['citedSource'] as String? ?? 'TNAU-CPG-2025',
      publicationDate: json['publicationDate'] as String? ?? '2025-05-10',
      dataAgeDays: (json['dataAgeDays'] as num?)?.toInt() ?? 14,
      queueStatus: json['queueStatus'] as String? ?? 'delivered',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'queryText': queryText,
      'payloadSizeBytes': payloadSizeBytes,
      'maxConstraintBytes': maxConstraintBytes,
      'recommendation': recommendation,
      'recommendationTamil': recommendationTamil,
      'essentialReason': essentialReason,
      'essentialReasonTamil': essentialReasonTamil,
      'citedSource': citedSource,
      'publicationDate': publicationDate,
      'dataAgeDays': dataAgeDays,
      'queueStatus': queueStatus,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
