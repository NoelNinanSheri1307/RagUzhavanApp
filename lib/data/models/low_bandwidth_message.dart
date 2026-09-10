class LowBandwidthMessage {
  final String id;
  final String queryText;
  final double payloadSizeKb;
  final String compressedSummary;
  final String compressedSummaryTamil;
  final String queueStatus; // 'queued', 'transmitting', 'delivered'
  final int retryCount;
  final DateTime timestamp;

  const LowBandwidthMessage({
    required this.id,
    required this.queryText,
    required this.payloadSizeKb,
    required this.compressedSummary,
    required this.compressedSummaryTamil,
    required this.queueStatus,
    required this.retryCount,
    required this.timestamp,
  });

  factory LowBandwidthMessage.fromJson(Map<String, dynamic> json) {
    return LowBandwidthMessage(
      id: json['id'] as String? ?? '',
      queryText: json['queryText'] as String? ?? '',
      payloadSizeKb: (json['payloadSizeKb'] as num?)?.toDouble() ?? 1.2,
      compressedSummary: json['compressedSummary'] as String? ?? '',
      compressedSummaryTamil: json['compressedSummaryTamil'] as String? ?? '',
      queueStatus: json['queueStatus'] as String? ?? 'delivered',
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'queryText': queryText,
      'payloadSizeKb': payloadSizeKb,
      'compressedSummary': compressedSummary,
      'compressedSummaryTamil': compressedSummaryTamil,
      'queueStatus': queueStatus,
      'retryCount': retryCount,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
