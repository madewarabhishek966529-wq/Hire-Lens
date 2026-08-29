class JobRequirement {
  final String id;
  final String title;
  final String category; // 'must_have', 'preferred', 'nice_to_have'
  final String rationale;
  final String importance; // 'HIGH', 'MEDIUM', 'LOW'

  const JobRequirement({
    required this.id,
    required this.title,
    required this.category,
    required this.rationale,
    required this.importance,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'rationale': rationale,
        'importance': importance,
      };

  factory JobRequirement.fromJson(Map<String, dynamic> json) => JobRequirement(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        category: json['category'] ?? 'must_have',
        rationale: json['rationale'] ?? '',
        importance: json['importance'] ?? 'HIGH',
      );
}

class Job {
  final String id;
  final String userId;
  final String title;
  final String company;
  final String location;
  final String employmentType;
  final String description;
  final String applicationUrl;
  final String seniority;
  final int minYearsExp;
  final List<JobRequirement> requirements;
  final DateTime createdAt;

  const Job({
    required this.id,
    required this.userId,
    required this.title,
    required this.company,
    required this.location,
    required this.employmentType,
    required this.description,
    required this.applicationUrl,
    required this.seniority,
    required this.minYearsExp,
    required this.requirements,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'company': company,
        'location': location,
        'employmentType': employmentType,
        'description': description,
        'applicationUrl': applicationUrl,
        'seniority': seniority,
        'minYearsExp': minYearsExp,
        'requirements': requirements.map((r) => r.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Job.fromJson(Map<String, dynamic> json) => Job(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        title: json['title'] ?? '',
        company: json['company'] ?? '',
        location: json['location'] ?? '',
        employmentType: json['employmentType'] ?? 'Full-time',
        description: json['description'] ?? '',
        applicationUrl: json['applicationUrl'] ?? '',
        seniority: json['seniority'] ?? 'Mid-Level',
        minYearsExp: json['minYearsExp'] ?? 2,
        requirements: (json['requirements'] as List<dynamic>?)
                ?.map((e) => JobRequirement.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );
}
