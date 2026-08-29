class CandidateProfile {
  final String id;
  final String userId;
  final String fullName;
  final String currentRole;
  final int yearsExperience;
  final String targetRole;
  final String targetIndustry;
  final String location;
  final String workPreference;
  final String summary;
  final List<String> skills;
  final List<Map<String, dynamic>> experience;
  final List<Map<String, dynamic>> projects;
  final List<Map<String, dynamic>> education;
  final List<String> certifications;
  final List<String> technologies;

  const CandidateProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.currentRole,
    required this.yearsExperience,
    required this.targetRole,
    required this.targetIndustry,
    required this.location,
    required this.workPreference,
    required this.summary,
    required this.skills,
    required this.experience,
    required this.projects,
    required this.education,
    required this.certifications,
    required this.technologies,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'currentRole': currentRole,
      'yearsExperience': yearsExperience,
      'targetRole': targetRole,
      'targetIndustry': targetIndustry,
      'location': location,
      'workPreference': workPreference,
      'summary': summary,
      'skills': skills,
      'experience': experience,
      'projects': projects,
      'education': education,
      'certifications': certifications,
      'technologies': technologies,
    };
  }

  factory CandidateProfile.fromJson(Map<String, dynamic> json) {
    return CandidateProfile(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? 'Alex Morgan',
      currentRole: json['currentRole'] ?? 'Flutter Developer',
      yearsExperience: json['yearsExperience'] ?? 2,
      targetRole: json['targetRole'] ?? 'Mobile Application Developer',
      targetIndustry: json['targetIndustry'] ?? 'Technology',
      location: json['location'] ?? 'Remote',
      workPreference: json['workPreference'] ?? 'Hybrid',
      summary: json['summary'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      experience: List<Map<String, dynamic>>.from(json['experience'] ?? []),
      projects: List<Map<String, dynamic>>.from(json['projects'] ?? []),
      education: List<Map<String, dynamic>>.from(json['education'] ?? []),
      certifications: List<String>.from(json['certifications'] ?? []),
      technologies: List<String>.from(json['technologies'] ?? []),
    );
  }
}
