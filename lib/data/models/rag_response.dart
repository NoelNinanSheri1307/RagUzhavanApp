import 'evidence_source.dart';
import 'clarification_question.dart';

enum ResponseStatus { grounded, clarificationNeeded, noData }

class RagResponse {
  final String id;
  final String queryId;
  final String responseText;
  final String responseTextTamil;
  
  // Structured Deterministic Rule Outputs
  final String recommendationSummary;
  final String recommendationSummaryTamil;
  final String whatToDo;
  final String whatToDoTamil;
  final String whenToApply;
  final String whenToApplyTamil;
  final String howMuchAmount;
  final String howMuchAmountTamil;
  final String whyReason;
  final String whyReasonTamil;
  final double groundingScore; // 0.0 to 1.0 (thin scientific indicator)
  final String ruleId;
  final String citedProvenance;

  final String language;
  final bool isGrounded;
  final List<EvidenceSource> evidenceSources;
  final List<ClarificationQuestion> clarificationQuestions;
  final DateTime timestamp;
  final ResponseStatus status;
  final String stateName;
  final String districtName;
  final String blockName;
  final String blockNameTamil;
  final String cropName;
  final String growthStage;
  final String season;
  final int averageDataAgeDays;

  const RagResponse({
    required this.id,
    required this.queryId,
    required this.responseText,
    required this.responseTextTamil,
    required this.recommendationSummary,
    required this.recommendationSummaryTamil,
    required this.whatToDo,
    required this.whatToDoTamil,
    required this.whenToApply,
    required this.whenToApplyTamil,
    required this.howMuchAmount,
    required this.howMuchAmountTamil,
    required this.whyReason,
    required this.whyReasonTamil,
    required this.groundingScore,
    required this.ruleId,
    required this.citedProvenance,
    required this.language,
    required this.isGrounded,
    required this.evidenceSources,
    required this.clarificationQuestions,
    required this.timestamp,
    required this.status,
    this.stateName = 'Tamil Nadu',
    required this.districtName,
    required this.blockName,
    this.blockNameTamil = '',
    required this.cropName,
    required this.growthStage,
    required this.season,
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
      recommendationSummary: json['recommendationSummary'] as String? ?? '',
      recommendationSummaryTamil: json['recommendationSummaryTamil'] as String? ?? '',
      whatToDo: json['whatToDo'] as String? ?? '',
      whatToDoTamil: json['whatToDoTamil'] as String? ?? '',
      whenToApply: json['whenToApply'] as String? ?? '',
      whenToApplyTamil: json['whenToApplyTamil'] as String? ?? '',
      howMuchAmount: json['howMuchAmount'] as String? ?? '',
      howMuchAmountTamil: json['howMuchAmountTamil'] as String? ?? '',
      whyReason: json['whyReason'] as String? ?? '',
      whyReasonTamil: json['whyReasonTamil'] as String? ?? '',
      groundingScore: (json['groundingScore'] as num?)?.toDouble() ?? 0.94,
      ruleId: json['ruleId'] as String? ?? 'RULE-TNAU-BLAST-01',
      citedProvenance: json['citedProvenance'] as String? ?? 'TNAU Crop Production Guide 2025',
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
      stateName: json['stateName'] as String? ?? 'Tamil Nadu',
      districtName: json['districtName'] as String? ?? 'Thanjavur',
      blockName: json['blockName'] as String? ?? 'Budalur',
      blockNameTamil: json['blockNameTamil'] as String? ?? 'பூதலூர்',
      cropName: json['cropName'] as String? ?? 'Paddy / Rice',
      growthStage: json['growthStage'] as String? ?? 'Tillering',
      season: json['season'] as String? ?? 'Kuruvai',
      averageDataAgeDays: (json['averageDataAgeDays'] as num?)?.toInt() ?? 14,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'queryId': queryId,
      'responseText': responseText,
      'responseTextTamil': responseTextTamil,
      'recommendationSummary': recommendationSummary,
      'recommendationSummaryTamil': recommendationSummaryTamil,
      'whatToDo': whatToDo,
      'whatToDoTamil': whatToDoTamil,
      'whenToApply': whenToApply,
      'whenToApplyTamil': whenToApplyTamil,
      'howMuchAmount': howMuchAmount,
      'howMuchAmountTamil': howMuchAmountTamil,
      'whyReason': whyReason,
      'whyReasonTamil': whyReasonTamil,
      'groundingScore': groundingScore,
      'ruleId': ruleId,
      'citedProvenance': citedProvenance,
      'language': language,
      'isGrounded': isGrounded,
      'evidenceSources': evidenceSources.map((e) => e.toJson()).toList(),
      'clarificationQuestions': clarificationQuestions.map((e) => e.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'stateName': stateName,
      'districtName': districtName,
      'blockName': blockName,
      'blockNameTamil': blockNameTamil,
      'cropName': cropName,
      'growthStage': growthStage,
      'season': season,
      'averageDataAgeDays': averageDataAgeDays,
    };
  }
}
