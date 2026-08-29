enum InterviewMode { quick, full, technical, behavioral, project }

class InterviewEvaluation {
  final String questionId;
  final int overallScore; // 0-100
  final int relevanceScore;
  final int specificityScore;
  final int technicalDepthScore;
  final int structureScore;
  final Map<String, String> starAnalysis; // Situation, Task, Action, Result
  final List<String> whatWorked;
  final List<String> whatWasWeak;
  final String betterStructure;
  final String suggestedFollowUp;

  const InterviewEvaluation({
    required this.questionId,
    required this.overallScore,
    required this.relevanceScore,
    required this.specificityScore,
    required this.technicalDepthScore,
    required this.structureScore,
    required this.starAnalysis,
    required this.whatWorked,
    required this.whatWasWeak,
    required this.betterStructure,
    required this.suggestedFollowUp,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'overallScore': overallScore,
        'relevanceScore': relevanceScore,
        'specificityScore': specificityScore,
        'technicalDepthScore': technicalDepthScore,
        'structureScore': structureScore,
        'starAnalysis': starAnalysis,
        'whatWorked': whatWorked,
        'whatWasWeak': whatWasWeak,
        'betterStructure': betterStructure,
        'suggestedFollowUp': suggestedFollowUp,
      };

  factory InterviewEvaluation.fromJson(Map<String, dynamic> json) =>
      InterviewEvaluation(
        questionId: json['questionId'] ?? '',
        overallScore: json['overallScore'] ?? 78,
        relevanceScore: json['relevanceScore'] ?? 88,
        specificityScore: json['specificityScore'] ?? 63,
        technicalDepthScore: json['technicalDepthScore'] ?? 81,
        structureScore: json['structureScore'] ?? 74,
        starAnalysis: Map<String, String>.from(json['starAnalysis'] ?? {}),
        whatWorked: List<String>.from(json['whatWorked'] ?? []),
        whatWasWeak: List<String>.from(json['whatWasWeak'] ?? []),
        betterStructure: json['betterStructure'] ?? '',
        suggestedFollowUp: json['suggestedFollowUp'] ?? '',
      );
}

class InterviewQuestion {
  final String id;
  final int index;
  final String text;
  final String category; // Technical, Behavioral, etc.
  final String? userAnswer;
  final InterviewEvaluation? evaluation;

  const InterviewQuestion({
    required this.id,
    required this.index,
    required this.text,
    required this.category,
    this.userAnswer,
    this.evaluation,
  });

  InterviewQuestion copyWith({
    String? userAnswer,
    InterviewEvaluation? evaluation,
  }) {
    return InterviewQuestion(
      id: id,
      index: index,
      text: text,
      category: category,
      userAnswer: userAnswer ?? this.userAnswer,
      evaluation: evaluation ?? this.evaluation,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'index': index,
        'text': text,
        'category': category,
        'userAnswer': userAnswer,
        'evaluation': evaluation?.toJson(),
      };

  factory InterviewQuestion.fromJson(Map<String, dynamic> json) =>
      InterviewQuestion(
        id: json['id'] ?? '',
        index: json['index'] ?? 1,
        text: json['text'] ?? '',
        category: json['category'] ?? 'Technical',
        userAnswer: json['userAnswer'],
        evaluation: json['evaluation'] != null
            ? InterviewEvaluation.fromJson(
                json['evaluation'] as Map<String, dynamic>)
            : null,
      );
}

class InterviewSession {
  final String id;
  final String jobId;
  final String jobTitle;
  final InterviewMode mode;
  final int totalQuestions;
  final List<InterviewQuestion> questions;
  final int averageScore;
  final bool isCompleted;
  final DateTime createdAt;

  const InterviewSession({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.mode,
    required this.totalQuestions,
    required this.questions,
    required this.averageScore,
    required this.isCompleted,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'jobId': jobId,
        'jobTitle': jobTitle,
        'mode': mode.name,
        'totalQuestions': totalQuestions,
        'questions': questions.map((q) => q.toJson()).toList(),
        'averageScore': averageScore,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
      };

  factory InterviewSession.fromJson(Map<String, dynamic> json) =>
      InterviewSession(
        id: json['id'] ?? '',
        jobId: json['jobId'] ?? '',
        jobTitle: json['jobTitle'] ?? 'Mobile Application Developer',
        mode: InterviewMode.values.firstWhere(
          (e) => e.name == json['mode'],
          orElse: () => InterviewMode.quick,
        ),
        totalQuestions: json['totalQuestions'] ?? 5,
        questions: (json['questions'] as List<dynamic>?)
                ?.map((e) =>
                    InterviewQuestion.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        averageScore: json['averageScore'] ?? 75,
        isCompleted: json['isCompleted'] ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );
}
