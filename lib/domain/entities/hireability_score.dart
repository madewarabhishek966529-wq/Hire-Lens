class ScoreCategoryBreakdown {
  final String categoryName;
  final int score; // 0 - 100
  final String explanation;
  final List<String> positiveFactors;
  final List<String> negativeFactors;

  const ScoreCategoryBreakdown({
    required this.categoryName,
    required this.score,
    required this.explanation,
    required this.positiveFactors,
    required this.negativeFactors,
  });

  Map<String, dynamic> toJson() => {
        'categoryName': categoryName,
        'score': score,
        'explanation': explanation,
        'positiveFactors': positiveFactors,
        'negativeFactors': negativeFactors,
      };

  factory ScoreCategoryBreakdown.fromJson(Map<String, dynamic> json) =>
      ScoreCategoryBreakdown(
        categoryName: json['categoryName'] ?? '',
        score: json['score'] ?? 0,
        explanation: json['explanation'] ?? '',
        positiveFactors: List<String>.from(json['positiveFactors'] ?? []),
        negativeFactors: List<String>.from(json['negativeFactors'] ?? []),
      );
}

class HireabilityScore {
  final String id;
  final String jobId;
  final int overallScore; // 0 - 100
  final int scoreChange; // e.g. +6
  final int technicalSkillsScore;
  final int experienceRelevanceScore;
  final int projectEvidenceScore;
  final int resumeQualityScore;
  final int keywordAlignmentScore;
  final int seniorityAlignmentScore;
  final List<ScoreCategoryBreakdown> breakdowns;
  final String summaryRationale;
  final DateTime calculatedAt;

  const HireabilityScore({
    required this.id,
    required this.jobId,
    required this.overallScore,
    required this.scoreChange,
    required this.technicalSkillsScore,
    required this.experienceRelevanceScore,
    required this.projectEvidenceScore,
    required this.resumeQualityScore,
    required this.keywordAlignmentScore,
    required this.seniorityAlignmentScore,
    required this.breakdowns,
    required this.summaryRationale,
    required this.calculatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'jobId': jobId,
        'overallScore': overallScore,
        'scoreChange': scoreChange,
        'technicalSkillsScore': technicalSkillsScore,
        'experienceRelevanceScore': experienceRelevanceScore,
        'projectEvidenceScore': projectEvidenceScore,
        'resumeQualityScore': resumeQualityScore,
        'keywordAlignmentScore': keywordAlignmentScore,
        'seniorityAlignmentScore': seniorityAlignmentScore,
        'breakdowns': breakdowns.map((b) => b.toJson()).toList(),
        'summaryRationale': summaryRationale,
        'calculatedAt': calculatedAt.toIso8601String(),
      };

  factory HireabilityScore.fromJson(Map<String, dynamic> json) =>
      HireabilityScore(
        id: json['id'] ?? '',
        jobId: json['jobId'] ?? '',
        overallScore: json['overallScore'] ?? 74,
        scoreChange: json['scoreChange'] ?? 6,
        technicalSkillsScore: json['technicalSkillsScore'] ?? 82,
        experienceRelevanceScore: json['experienceRelevanceScore'] ?? 76,
        projectEvidenceScore: json['projectEvidenceScore'] ?? 61,
        resumeQualityScore: json['resumeQualityScore'] ?? 79,
        keywordAlignmentScore: json['keywordAlignmentScore'] ?? 84,
        seniorityAlignmentScore: json['seniorityAlignmentScore'] ?? 68,
        breakdowns: (json['breakdowns'] as List<dynamic>?)
                ?.map((e) => ScoreCategoryBreakdown.fromJson(
                    e as Map<String, dynamic>))
                .toList() ??
            [],
        summaryRationale: json['summaryRationale'] ??
            'An estimated job-fit score based on the supplied resume and job description.',
        calculatedAt: json['calculatedAt'] != null
            ? DateTime.parse(json['calculatedAt'])
            : DateTime.now(),
      );
}
