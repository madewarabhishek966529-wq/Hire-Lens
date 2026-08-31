import 'package:uuid/uuid.dart';
import '../../domain/entities/candidate_profile.dart';
import '../../domain/entities/job.dart';
import '../../domain/entities/hireability_score.dart';
import '../../domain/entities/skill_gap.dart';
import '../../domain/entities/evidence.dart';
import '../../domain/entities/resume_suggestion.dart';
import '../../domain/entities/interview.dart';
import 'ai_provider.dart';

class FallbackAiEngine implements AiProvider {
  final _uuid = const Uuid();

  @override
  Future<CandidateProfile> parseResume(String rawText, {String? userId}) async {
    final lower = rawText.toLowerCase();

    // Extract skills deterministically
    final knownSkills = [
      'Flutter', 'Dart', 'React', 'TypeScript', 'Node.js', 'Python', 'Java',
      'Kotlin', 'Swift', 'REST APIs', 'GraphQL', 'Firebase', 'SQLite',
      'PostgreSQL', 'Docker', 'Kubernetes', 'AWS', 'Git', 'CI/CD'
    ];
    final foundSkills = <String>[];
    for (final skill in knownSkills) {
      if (lower.contains(skill.toLowerCase())) {
        foundSkills.add(skill);
      }
    }
    if (foundSkills.isEmpty) {
      foundSkills.addAll(['Flutter', 'Dart', 'REST APIs', 'Git']);
    }

    return CandidateProfile(
      id: _uuid.v4(),
      userId: userId ?? 'user-current',
      fullName: _extractName(rawText),
      currentRole: _extractRole(rawText),
      yearsExperience: _extractYearsExp(rawText),
      targetRole: 'Mobile Application Developer',
      targetIndustry: 'Technology',
      location: 'Remote / Hybrid',
      workPreference: 'Full-time',
      summary: rawText.length > 200 ? rawText.substring(0, 200) : rawText,
      skills: foundSkills,
      experience: [
        {
          'title': _extractRole(rawText),
          'company': 'Tech Corp',
          'duration': '2023 - Present',
          'bullets': [
            'Developed cross-platform mobile software features.',
            'Collaborated with API backend teams to improve app performance.'
          ]
        }
      ],
      projects: [
        {
          'name': 'Portfolio App',
          'tech': foundSkills.take(3).join(', '),
          'description': 'Mobile application displaying structured candidate experience.'
        }
      ],
      education: [
        {
          'degree': 'B.S. in Computer Science',
          'institution': 'University Tech',
          'year': '2023'
        }
      ],
      certifications: ['AWS Cloud Practitioner'],
      technologies: foundSkills,
    );
  }

  @override
  Future<Job> analyzeJob(String title, String company, String jdText, {String? userId}) async {
    final lower = jdText.toLowerCase();
    final requirements = <JobRequirement>[];

    if (lower.contains('flutter') || lower.contains('mobile') || lower.contains('react')) {
      requirements.add(const JobRequirement(
        id: 'req-core-framework',
        title: 'Mobile Framework (Flutter/Dart)',
        category: 'must_have',
        rationale: 'Primary development framework mentioned in job overview.',
        importance: 'HIGH',
      ));
    }
    if (lower.contains('api') || lower.contains('rest') || lower.contains('sqlite')) {
      requirements.add(const JobRequirement(
        id: 'req-apis-db',
        title: 'REST APIs & Local Storage',
        category: 'must_have',
        rationale: 'Required for client-server communication and caching.',
        importance: 'HIGH',
      ));
    }
    if (lower.contains('aws') || lower.contains('cloud') || lower.contains('devops')) {
      requirements.add(const JobRequirement(
        id: 'req-aws-cloud',
        title: 'AWS Cloud & Infrastructure',
        category: 'preferred',
        rationale: 'Useful for backend services and cloud deployments.',
        importance: 'MEDIUM',
      ));
    }
    if (lower.contains('kubernetes') || lower.contains('docker') || lower.contains('ci/cd')) {
      requirements.add(const JobRequirement(
        id: 'req-container',
        title: 'Kubernetes & CI/CD Pipelines',
        category: 'nice_to_have',
        rationale: 'Helpful for microservices deployment.',
        importance: 'LOW',
      ));
    }

    if (requirements.isEmpty) {
      requirements.addAll([
        const JobRequirement(
          id: 'req-1',
          title: 'Software Development Fundamentals',
          category: 'must_have',
          rationale: 'Core programming requirement.',
          importance: 'HIGH',
        ),
        const JobRequirement(
          id: 'req-2',
          title: 'REST API Integration',
          category: 'must_have',
          rationale: 'Data sync requirement.',
          importance: 'HIGH',
        ),
      ]);
    }

    return Job(
      id: _uuid.v4(),
      userId: userId ?? 'user-current',
      title: title.isNotEmpty ? title : 'Mobile Application Developer',
      company: company.isNotEmpty ? company : 'TechCorp',
      location: 'Remote',
      employmentType: 'Full-time',
      description: jdText,
      applicationUrl: '',
      seniority: 'Mid-Level',
      minYearsExp: 2,
      requirements: requirements,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<HireabilityScore> calculateHireabilityScore(CandidateProfile candidate, Job job) async {
    int totalReqs = job.requirements.length;
    int matchedCount = 0;

    for (final req in job.requirements) {
      final titleLower = req.title.toLowerCase();
      final hasMatch = candidate.skills.any((s) => titleLower.contains(s.toLowerCase())) ||
          candidate.technologies.any((t) => titleLower.contains(t.toLowerCase()));
      if (hasMatch) matchedCount++;
    }

    double matchRatio = totalReqs > 0 ? (matchedCount / totalReqs) : 0.75;
    int overall = (60 + (matchRatio * 35)).round().clamp(50, 95);

    return HireabilityScore(
      id: _uuid.v4(),
      jobId: job.id,
      overallScore: overall,
      scoreChange: 6,
      technicalSkillsScore: (overall * 1.1).round().clamp(60, 98),
      experienceRelevanceScore: (overall * 0.98).round().clamp(55, 95),
      projectEvidenceScore: (overall * 0.85).round().clamp(50, 90),
      resumeQualityScore: (overall * 1.05).round().clamp(65, 96),
      keywordAlignmentScore: (overall * 1.08).round().clamp(60, 98),
      seniorityAlignmentScore: (overall * 0.9).round().clamp(50, 90),
      breakdowns: [
        ScoreCategoryBreakdown(
          categoryName: 'Technical Skills',
          score: (overall * 1.1).round().clamp(60, 98),
          explanation: 'Calculated from direct skill and technology alignment in resume.',
          positiveFactors: ['Strong core language match', 'Relevant state management'],
          negativeFactors: ['Missing cloud containerization evidence'],
        ),
        ScoreCategoryBreakdown(
          categoryName: 'Experience Relevance',
          score: (overall * 0.98).round().clamp(55, 95),
          explanation: 'Based on total years experience and target role alignment.',
          positiveFactors: ['Direct production app deployment experience'],
          negativeFactors: ['Fewer years than senior requirement'],
        ),
      ],
      summaryRationale:
          'Your profile aligns closely ($overall%) with ${job.title} at ${job.company}. Focus on building evidence for missing infrastructure skills.',
      calculatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<EvidenceItem>> extractEvidence(CandidateProfile candidate, Job job) async {
    final list = <EvidenceItem>[];
    for (final req in job.requirements) {
      final reqLower = req.title.toLowerCase();
      String? foundQuote;
      EvidenceConfidence conf = EvidenceConfidence.none;

      for (final exp in candidate.experience) {
        final bullets = List<String>.from(exp['bullets'] ?? []);
        for (final b in bullets) {
          if (b.toLowerCase().contains('flutter') && reqLower.contains('flutter')) {
            foundQuote = b;
            conf = EvidenceConfidence.high;
            break;
          } else if (b.toLowerCase().contains('api') && reqLower.contains('api')) {
            foundQuote = b;
            conf = EvidenceConfidence.high;
            break;
          } else if (b.toLowerCase().contains('aws') && reqLower.contains('aws')) {
            foundQuote = b;
            conf = EvidenceConfidence.medium;
            break;
          }
        }
      }

      list.add(EvidenceItem(
        id: _uuid.v4(),
        requirementId: req.id,
        requirementTitle: req.title,
        candidateQuote: foundQuote ?? 'No explicit evidence found in source resume.',
        confidence: conf,
        explanation: conf == EvidenceConfidence.none
            ? 'No candidate resume bullet explicitly demonstrates this requirement.'
            : 'Directly supported by candidate experience bullet.',
      ));
    }
    return list;
  }

  @override
  Future<List<SkillGap>> analyzeSkillGaps(CandidateProfile candidate, Job job, List<EvidenceItem> evidence) async {
    final gaps = <SkillGap>[];
    for (final item in evidence) {
      if (item.confidence == EvidenceConfidence.none) {
        gaps.add(SkillGap(
          id: _uuid.v4(),
          jobId: job.id,
          skillName: item.requirementTitle,
          status: GapMatchStatus.missing,
          priority: GapPriority.critical,
          currentEvidence: 'No supporting evidence found.',
          missingDetails: 'Lack of practical experience or project proof.',
          whyItMatters: 'Key requirement listed for ${job.title}.',
          recommendedAction: 'Build a small portfolio demo project highlighting ${item.requirementTitle}.',
          priorityScore: 90,
        ));
      } else if (item.confidence == EvidenceConfidence.medium) {
        gaps.add(SkillGap(
          id: _uuid.v4(),
          jobId: job.id,
          skillName: item.requirementTitle,
          status: GapMatchStatus.partial,
          priority: GapPriority.high,
          currentEvidence: item.candidateQuote,
          missingDetails: 'Mentions basic certification or tool usage, but lacks production scale evidence.',
          whyItMatters: 'Important requirement for role performance.',
          recommendedAction: 'Document specific deployment architecture or performance metrics in your resume.',
          priorityScore: 75,
        ));
      } else {
        gaps.add(SkillGap(
          id: _uuid.v4(),
          jobId: job.id,
          skillName: item.requirementTitle,
          status: GapMatchStatus.strong,
          priority: GapPriority.low,
          currentEvidence: item.candidateQuote,
          missingDetails: 'None. Strong evidence present.',
          whyItMatters: 'Solid foundation for job requirement.',
          recommendedAction: 'Maintain current experience presentation.',
          priorityScore: 30,
        ));
      }
    }
    gaps.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
    return gaps;
  }

  @override
  Future<List<ResumeSuggestion>> optimizeResume(CandidateProfile candidate, Job job) async {
    return [
      ResumeSuggestion(
        id: _uuid.v4(),
        jobId: job.id,
        originalBullet: 'Worked on mobile app features using Flutter.',
        suggestedBullet:
            'Developed cross-platform mobile features in Flutter & Dart, implementing clean architecture and Riverpod state management to ensure smooth UI responsiveness.',
        whyItChanged: 'Added specific framework details and clean architecture terminology matching target job.',
        matchedRequirement: 'Flutter & Dart Mobile Development',
        status: SuggestionStatus.pending,
        truthGuardFlags: [],
      ),
      ResumeSuggestion(
        id: _uuid.v4(),
        jobId: job.id,
        originalBullet: 'Handled database storage.',
        suggestedBullet:
            'Engineered offline-first local data caching using SQLite, reducing network requests by 45% and maintaining full offline app availability.',
        whyItChanged: 'Framed impact around offline data caching requirement.',
        matchedRequirement: 'REST APIs & SQLite Caching',
        status: SuggestionStatus.pending,
        truthGuardFlags: [
          const TruthGuardFlag(
            title: 'Potential Unsupported Metric',
            description: '"reducing network requests by 45%"',
            reason: 'This quantitative 45% metric does not appear in your source resume.',
          )
        ],
      ),
    ];
  }

  @override
  Future<List<TruthGuardFlag>> validateResumeTruth(String originalBullet, String suggestedBullet, CandidateProfile profile) async {
    final flags = <TruthGuardFlag>[];
    if (suggestedBullet.contains('%') && !originalBullet.contains('%')) {
      flags.add(const TruthGuardFlag(
        title: 'Invented Metric Warning',
        description: 'Suggested bullet contains percentage metrics.',
        reason: 'Source bullet did not contain quantitative metrics. Please verify accuracy.',
      ));
    }
    return flags;
  }

  @override
  Future<InterviewSession> generateInterviewSession(Job job, CandidateProfile profile, InterviewMode mode) async {
    final questions = [
      InterviewQuestion(
        id: _uuid.v4(),
        index: 1,
        text: 'Tell me about how you structure your Flutter applications and manage app state using Riverpod.',
        category: 'Technical',
      ),
      InterviewQuestion(
        id: _uuid.v4(),
        index: 2,
        text: 'Describe a challenging production bug you encountered with local SQLite caching or REST API synchronization, and how you resolved it.',
        category: 'Behavioral / Technical',
      ),
      InterviewQuestion(
        id: _uuid.v4(),
        index: 3,
        text: 'How do you ensure UI responsiveness when executing heavy data processing tasks in Dart?',
        category: 'Technical Depth',
      ),
    ];

    return InterviewSession(
      id: _uuid.v4(),
      jobId: job.id,
      jobTitle: job.title,
      mode: mode,
      totalQuestions: questions.length,
      questions: questions,
      averageScore: 0,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<InterviewEvaluation> evaluateInterviewAnswer(String questionId, String questionText, String answerText) async {
    int length = answerText.trim().length;
    int relevance = (70 + (length > 50 ? 15 : 5)).clamp(50, 95);
    int depth = (65 + (answerText.toLowerCase().contains('riverpod') || answerText.toLowerCase().contains('sqlite') ? 20 : 5)).clamp(50, 95);
    int overall = ((relevance + depth + 75 + 78) / 4).round();

    return InterviewEvaluation(
      questionId: questionId,
      overallScore: overall,
      relevanceScore: relevance,
      specificityScore: 72,
      technicalDepthScore: depth,
      structureScore: 78,
      starAnalysis: {
        'Situation': 'Building mobile software component under specific requirements.',
        'Task': 'Ensure performance, clean state management, and reliable data sync.',
        'Action': answerText.length > 80 ? '${answerText.substring(0, 80)}...' : answerText,
        'Result': 'Achieved responsive UI and clean architecture structure.'
      },
      whatWorked: [
        'Good relevance to the question domain.',
        'Mentioned appropriate technical framework concepts.'
      ],
      whatWasWeak: [
        'Could include explicit quantitative metrics or latency impact.'
      ],
      betterStructure:
          'Structure response with situation background, technical action taken, and measurable outcome.',
      suggestedFollowUp: 'What automated testing strategy did you use to verify this implementation?',
    );
  }

  // Helpers
  String _extractName(String text) {
    final lines = text.split('\n');
    if (lines.isNotEmpty && lines.first.trim().isNotEmpty) {
      return lines.first.trim();
    }
    return 'Alex Morgan';
  }

  String _extractRole(String text) {
    if (text.toLowerCase().contains('flutter')) return 'Flutter Mobile Engineer';
    if (text.toLowerCase().contains('react')) return 'Frontend Developer';
    return 'Software Developer';
  }

  int _extractYearsExp(String text) {
    if (text.contains('3 years') || text.contains('3+ years')) return 3;
    if (text.contains('5 years')) return 5;
    return 2;
  }
}
