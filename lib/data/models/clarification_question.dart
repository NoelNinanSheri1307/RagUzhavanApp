class ClarificationQuestion {
  final String id;
  final String questionText;
  final String questionTextTamil;
  final String fieldName;
  final List<String> options;
  final List<String> optionsTamil;
  final bool isRequired;

  const ClarificationQuestion({
    required this.id,
    required this.questionText,
    required this.questionTextTamil,
    required this.fieldName,
    required this.options,
    required this.optionsTamil,
    this.isRequired = true,
  });

  factory ClarificationQuestion.fromJson(Map<String, dynamic> json) {
    return ClarificationQuestion(
      id: json['id'] as String? ?? '',
      questionText: json['questionText'] as String? ?? '',
      questionTextTamil: json['questionTextTamil'] as String? ?? '',
      fieldName: json['fieldName'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      optionsTamil: (json['optionsTamil'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isRequired: json['isRequired'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'questionTextTamil': questionTextTamil,
      'fieldName': fieldName,
      'options': options,
      'optionsTamil': optionsTamil,
      'isRequired': isRequired,
    };
  }
}
