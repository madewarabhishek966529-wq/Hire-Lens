enum EvidenceConfidence { high, medium, low, none }

class EvidenceItem {
  final String id;
  final String requirementId;
  final String requirementTitle;
  final String candidateQuote;
  final EvidenceConfidence confidence;
  final String explanation;

  const EvidenceItem({
    required this.id,
    required this.requirementId,
    required this.requirementTitle,
    required this.candidateQuote,
    required this.confidence,
    required this.explanation,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'requirementId': requirementId,
        'requirementTitle': requirementTitle,
        'candidateQuote': candidateQuote,
        'confidence': confidence.name,
        'explanation': explanation,
      };

  factory EvidenceItem.fromJson(Map<String, dynamic> json) => EvidenceItem(
        id: json['id'] ?? '',
        requirementId: json['requirementId'] ?? '',
        requirementTitle: json['requirementTitle'] ?? '',
        candidateQuote: json['candidateQuote'] ?? '',
        confidence: EvidenceConfidence.values.firstWhere(
          (e) => e.name == json['confidence'],
          orElse: () => EvidenceConfidence.none,
        ),
        explanation: json['explanation'] ?? '',
      );
}
