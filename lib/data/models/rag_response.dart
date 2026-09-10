import 'evidence_source.dart';
import 'clarification_question.dart';

enum ResponseStatus { grounded, clarificationNeeded, noData }

class RagResponse {
  final String id;
  final String queryId;
  final String responseText;
  final String responseTextTamil;
  final String language;
  final bool isGrounded;
  final List<EvidenceSource> evidenceSources;
  final List<ClarificationQuestion> clarificationQuestions;
  final DateTime timestamp;
  final ResponseStatus status;
  final String districtName;
  final String cropName;
  final int averageDataAgeDays;

  const RagResponse({
    required this.id,
    required this.queryId,
    required this.responseText,
    required this.responseTextTamil,
    required this.language,
    required this.isGrounded,
    required this.evidenceSources,
    required this.clarificationQuestions,
    required this.timestamp,
    required this.status,
    required this.districtName,
    required this.cropName,
    required this.averageDataAgeDays,
  });

  factory RagResponse.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'grounded';
    ResponseStatus statusVal = ResponseStatus.grounded;
    if (statusStr == 'clarification_needed') {
      statusVal = ResponseStatus.clarificationNeeded;
    } else if (statusStr == 'no_data') {
      statusVal = ResponseStatus.noData;
    }

    return RagResponse(
      id: json['id'] as String? ?? '',
      queryId: json['queryId'] as String? ?? '',
      responseText: json['responseText'] as String? ?? '',
      responseTextTamil: json['responseTextTamil'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
      isGrounded: json['isGrounded'] as bool? ?? true,
      evidenceSources: (json['evidenceSources'] as List<dynamic>?)
              ?.map((e) => EvidenceSource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      clarificationQuestions: (json['clarificationQuestions'] as List<dynamic>?)
              ?.map((e) => ClarificationQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      status: statusVal,
      districtName: json['districtName'] as String? ?? 'Thanjavur',
      cropName: json['cropName'] as String? ?? 'Rice / Paddy',
      averageDataAgeDays: (json['averageDataAgeDays'] as num?)?.toInt() ?? 14,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'queryId': queryId,
      'responseText': responseText,
      'responseTextTamil': responseTextTamil,
      'language': language,
      'isGrounded': isGrounded,
      'evidenceSources': evidenceSources.map((e) => e.toJson()).toList(),
      'clarificationQuestions': clarificationQuestions.map((e) => e.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'districtName': districtName,
      'cropName': cropName,
      'averageDataAgeDays': averageDataAgeDays,
    };
  }
}
