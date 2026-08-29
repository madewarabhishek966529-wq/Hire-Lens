enum ApplicationStage {
  saved,
  applied,
  recruiterScreen,
  technicalInterview,
  finalRound,
  offer,
  rejected
}

class ApplicationTrack {
  final String id;
  final String jobId;
  final String jobTitle;
  final String companyName;
  final ApplicationStage stage;
  final String notes;
  final DateTime appliedDate;
  final DateTime? followUpDate;

  const ApplicationTrack({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.stage,
    required this.notes,
    required this.appliedDate,
    this.followUpDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'jobId': jobId,
        'jobTitle': jobTitle,
        'companyName': companyName,
        'stage': stage.name,
        'notes': notes,
        'appliedDate': appliedDate.toIso8601String(),
        'followUpDate': followUpDate?.toIso8601String(),
      };

  factory ApplicationTrack.fromJson(Map<String, dynamic> json) =>
      ApplicationTrack(
        id: json['id'] ?? '',
        jobId: json['jobId'] ?? '',
        jobTitle: json['jobTitle'] ?? '',
        companyName: json['companyName'] ?? '',
        stage: ApplicationStage.values.firstWhere(
          (e) => e.name == json['stage'],
          orElse: () => ApplicationStage.saved,
        ),
        notes: json['notes'] ?? '',
        appliedDate: json['appliedDate'] != null
            ? DateTime.parse(json['appliedDate'])
            : DateTime.now(),
        followUpDate: json['followUpDate'] != null
            ? DateTime.parse(json['followUpDate'])
            : null,
      );
}
