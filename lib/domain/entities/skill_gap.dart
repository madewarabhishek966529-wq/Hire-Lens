enum GapMatchStatus { strong, partial, missing }

enum GapPriority { critical, high, medium, low }

class SkillGap {
  final String id;
  final String jobId;
  final String skillName;
  final GapMatchStatus status;
  final GapPriority priority;
  final String currentEvidence;
  final String missingDetails;
  final String whyItMatters;
  final String recommendedAction;
  final int priorityScore; // Calculated numeric score

  const SkillGap({
    required this.id,
    required this.jobId,
    required this.skillName,
    required this.status,
    required this.priority,
    required this.currentEvidence,
    required this.missingDetails,
    required this.whyItMatters,
    required this.recommendedAction,
    required this.priorityScore,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'jobId': jobId,
        'skillName': skillName,
        'status': status.name,
        'priority': priority.name,
        'currentEvidence': currentEvidence,
        'missingDetails': missingDetails,
        'whyItMatters': whyItMatters,
        'recommendedAction': recommendedAction,
        'priorityScore': priorityScore,
      };

  factory SkillGap.fromJson(Map<String, dynamic> json) => SkillGap(
        id: json['id'] ?? '',
        jobId: json['jobId'] ?? '',
        skillName: json['skillName'] ?? '',
        status: GapMatchStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => GapMatchStatus.partial,
        ),
        priority: GapPriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => GapPriority.high,
        ),
        currentEvidence: json['currentEvidence'] ?? '',
        missingDetails: json['missingDetails'] ?? '',
        whyItMatters: json['whyItMatters'] ?? '',
        recommendedAction: json['recommendedAction'] ?? '',
        priorityScore: json['priorityScore'] ?? 80,
      );
}
