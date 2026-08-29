enum SuggestionStatus { pending, accepted, rejected }

class TruthGuardFlag {
  final String title; // e.g. "Unsupported Metric"
  final String description; // e.g. "Reduced API latency by 40%"
  final String reason; // e.g. "No evidence of this metric exists in source resume."

  const TruthGuardFlag({
    required this.title,
    required this.description,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'reason': reason,
      };

  factory TruthGuardFlag.fromJson(Map<String, dynamic> json) => TruthGuardFlag(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        reason: json['reason'] ?? '',
      );
}

class ResumeSuggestion {
  final String id;
  final String jobId;
  final String originalBullet;
  final String suggestedBullet;
  final String whyItChanged;
  final String matchedRequirement;
  final SuggestionStatus status;
  final List<TruthGuardFlag> truthGuardFlags;

  const ResumeSuggestion({
    required this.id,
    required this.jobId,
    required this.originalBullet,
    required this.suggestedBullet,
    required this.whyItChanged,
    required this.matchedRequirement,
    required this.status,
    required this.truthGuardFlags,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'jobId': jobId,
        'originalBullet': originalBullet,
        'suggestedBullet': suggestedBullet,
        'whyItChanged': whyItChanged,
        'matchedRequirement': matchedRequirement,
        'status': status.name,
        'truthGuardFlags': truthGuardFlags.map((f) => f.toJson()).toList(),
      };

  factory ResumeSuggestion.fromJson(Map<String, dynamic> json) =>
      ResumeSuggestion(
        id: json['id'] ?? '',
        jobId: json['jobId'] ?? '',
        originalBullet: json['originalBullet'] ?? '',
        suggestedBullet: json['suggestedBullet'] ?? '',
        whyItChanged: json['whyItChanged'] ?? '',
        matchedRequirement: json['matchedRequirement'] ?? '',
        status: SuggestionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => SuggestionStatus.pending,
        ),
        truthGuardFlags: (json['truthGuardFlags'] as List<dynamic>?)
                ?.map((e) => TruthGuardFlag.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
