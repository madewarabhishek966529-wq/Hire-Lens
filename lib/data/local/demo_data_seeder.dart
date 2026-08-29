import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/candidate_profile.dart';
import '../../domain/entities/job.dart';
import '../../domain/entities/hireability_score.dart';
import '../../domain/entities/skill_gap.dart';
import '../../domain/entities/evidence.dart';
import '../../domain/entities/resume_suggestion.dart';
import '../../domain/entities/interview.dart';
import '../../domain/entities/application.dart';

class DemoDataSeeder {
  static const String demoUserId = 'demo-user-alex';
  static const String demoJobId = 'demo-job-techcorp';

  static Future<void> seedInitialData(Database db) async {
    // 1. Candidate Profile (Alex Morgan)
    final profile = CandidateProfile(
      id: 'profile-alex',
      userId: demoUserId,
      fullName: 'Alex Morgan',
      currentRole: 'Flutter Developer',
      yearsExperience: 2,
      targetRole: 'Mobile Application Developer',
      targetIndustry: 'Software / FinTech',
      location: 'San Francisco, CA (Remote)',
      workPreference: 'Hybrid / Remote',
      summary:
          'Mobile Engineer with 2+ years of experience building cross-platform applications using Flutter, Dart, Firebase, and REST APIs. Passionate about performant UI and clean architecture.',
      skills: [
        'Flutter',
        'Dart',
        'State Management (Riverpod)',
        'REST APIs',
        'Firebase',
        'SQLite / Drift',
        'Git',
        'CI/CD Pipelines'
      ],
      experience: [
        {
          'title': 'Flutter Mobile Developer',
          'company': 'AppScale Labs',
          'duration': '2024 - Present (1.5 yrs)',
          'bullets': [
            'Architected and deployed 2 client Flutter applications on Google Play Store and Apple App Store.',
            'Integrated Dio REST client with Riverpod state management for dynamic real-time data caching.',
            'Collaborated with UX designers to craft high-fidelity Material 3 design widgets.',
          ]
        },
        {
          'title': 'Junior Software Engineer',
          'company': 'TechStarter Inc',
          'duration': '2023 - 2024 (1 yr)',
          'bullets': [
            'Built responsive web interfaces and modular backend components in Dart and Node.js.',
            'Optimized local SQLite database query indexing, cutting local render latency by 25%.',
          ]
        }
      ],
      projects: [
        {
          'name': 'FinanceTracker Mobile',
          'tech': 'Flutter, SQLite, Provider, Charts',
          'description':
              'Offline-first personal budget manager app downloaded 10,000+ times.',
        },
        {
          'name': 'CloudSync SDK',
          'tech': 'Dart, Dio, WebSockets',
          'description':
              'Open-source background sync engine for mobile offline resilience.',
        }
      ],
      education: [
        {
          'degree': 'B.S. in Computer Science',
          'institution': 'University of California, Davis',
          'year': '2023'
        }
      ],
      certifications: ['AWS Certified Cloud Practitioner'],
      technologies: ['Flutter', 'Dart', 'Android', 'iOS', 'Git', 'SQLite', 'Firebase', 'AWS Lambda'],
    );

    await db.insert('profiles', {
      'id': profile.id,
      'userId': profile.userId,
      'data': jsonEncode(profile.toJson()),
    });

    // 2. Target Job (Mobile Application Developer at TechCorp)
    final job = Job(
      id: demoJobId,
      userId: demoUserId,
      title: 'Mobile Application Developer',
      company: 'TechCorp Solutions',
      location: 'San Francisco, CA',
      employmentType: 'Full-time',
      description: '''
We are looking for a Senior/Mid Mobile Application Developer to build high-performance iOS and Android applications using Flutter and Dart.
Requirements:
- 2+ years experience building production mobile apps with Flutter & Dart.
- Strong knowledge of state management (Riverpod, Bloc, or Provider).
- Experience consuming REST APIs and handling offline data caching via SQLite.
- Strong understanding of mobile UI/UX and Material 3 design system.
- Experience with AWS deployment, CI/CD automated test pipelines, and Kubernetes containerization (Preferred).
''',
      applicationUrl: 'https://techcorp.example/careers/mobile-dev',
      seniority: 'Mid-Level',
      minYearsExp: 2,
      requirements: const [
        JobRequirement(
          id: 'req-flutter',
          title: 'Flutter & Dart Mobile Development',
          category: 'must_have',
          rationale: 'Core framework specified for building cross-platform apps.',
          importance: 'HIGH',
        ),
        JobRequirement(
          id: 'req-rest-sqlite',
          title: 'REST APIs & SQLite Caching',
          category: 'must_have',
          rationale: 'Essential for server interaction and offline resilience.',
          importance: 'HIGH',
        ),
        JobRequirement(
          id: 'req-state-mgmt',
          title: 'Riverpod / Modern State Management',
          category: 'must_have',
          rationale: 'Needed for structured, predictable app state flow.',
          importance: 'HIGH',
        ),
        JobRequirement(
          id: 'req-aws-deploy',
          title: 'AWS Deployment & Infrastructure',
          category: 'preferred',
          rationale: 'Useful for backend API integration and deployment tasks.',
          importance: 'MEDIUM',
        ),
        JobRequirement(
          id: 'req-k8s',
          title: 'Kubernetes & Container Orchestration',
          category: 'nice_to_have',
          rationale: 'Helpful for cloud microservices, but not critical for mobile frontend.',
          importance: 'LOW',
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    );

    await db.insert('jobs', {
      'id': job.id,
      'userId': job.userId,
      'title': job.title,
      'company': job.company,
      'data': jsonEncode(job.toJson()),
      'createdAt': job.createdAt.toIso8601String(),
    });

    // 3. Hireability Score (74 / 100)
    final score = HireabilityScore(
      id: 'score-techcorp',
      jobId: demoJobId,
      overallScore: 74,
      scoreChange: 6,
      technicalSkillsScore: 82,
      experienceRelevanceScore: 76,
      projectEvidenceScore: 61,
      resumeQualityScore: 79,
      keywordAlignmentScore: 84,
      seniorityAlignmentScore: 68,
      breakdowns: const [
        ScoreCategoryBreakdown(
          categoryName: 'Technical Skills',
          score: 82,
          explanation: 'Strong match for Flutter, Dart, Riverpod, and REST APIs.',
          positiveFactors: ['Strong Flutter experience', 'Solid Dart expertise'],
          negativeFactors: ['No Kubernetes evidence'],
        ),
        ScoreCategoryBreakdown(
          categoryName: 'Experience Relevance',
          score: 76,
          explanation: '2 years of dedicated mobile development experience.',
          positiveFactors: ['Direct cross-platform production apps shipped'],
          negativeFactors: ['Limited experience with large scale backend deployment'],
        ),
        ScoreCategoryBreakdown(
          categoryName: 'Project Evidence',
          score: 61,
          explanation: 'Solid offline budget app project, but missing AWS deployment evidence.',
          positiveFactors: ['FinanceTracker offline SQLite app'],
          negativeFactors: ['Lacks production cloud deployment metrics'],
        ),
        ScoreCategoryBreakdown(
          categoryName: 'Resume Quality',
          score: 79,
          explanation: 'Clean layout and clear technical bullet structure.',
          positiveFactors: ['Action-verb bullet phrasing'],
          negativeFactors: ['Some bullets lack quantitative impact metrics'],
        ),
      ],
      summaryRationale:
          'Your profile is a strong 74% match for TechCorp Mobile Developer. Your biggest remaining gap is production AWS deployment and infrastructure evidence.',
      calculatedAt: DateTime.now(),
    );

    await db.insert('hireability_scores', {
      'id': score.id,
      'jobId': score.jobId,
      'overallScore': score.overallScore,
      'data': jsonEncode(score.toJson()),
      'calculatedAt': score.calculatedAt.toIso8601String(),
    });

    // 4. Skill Gaps & Priorities
    final gaps = [
      const SkillGap(
        id: 'gap-aws',
        jobId: demoJobId,
        skillName: 'AWS Deployment & Monitoring',
        status: GapMatchStatus.partial,
        priority: GapPriority.critical,
        currentEvidence: 'Mentions AWS Certified Cloud Practitioner & AWS Lambda.',
        missingDetails: 'Does not demonstrate production deployment pipelines or cloud monitoring.',
        whyItMatters: 'TechCorp values developers who can deploy and monitor mobile backend services.',
        recommendedAction: 'Build and document a Flutter + AWS Serverless deployment project.',
        priorityScore: 92,
      ),
      const SkillGap(
        id: 'gap-k8s',
        jobId: demoJobId,
        skillName: 'Kubernetes & CI/CD',
        status: GapMatchStatus.missing,
        priority: GapPriority.medium,
        currentEvidence: 'No supporting evidence found in resume.',
        missingDetails: 'Container orchestration and automated cluster deployment.',
        whyItMatters: 'Nice to have for backend microservice integrations.',
        recommendedAction: 'Complete a brief Docker/Kubernetes container deployment tutorial.',
        priorityScore: 65,
      ),
      const SkillGap(
        id: 'gap-testing',
        jobId: demoJobId,
        skillName: 'Automated Flutter Testing',
        status: GapMatchStatus.strong,
        priority: GapPriority.low,
        currentEvidence: 'Unit tests and widget testing experience mentioned.',
        missingDetails: 'Integration UI testing framework specifics.',
        whyItMatters: 'Ensures high quality app releases.',
        recommendedAction: 'Add integration testing details to your project bullets.',
        priorityScore: 35,
      ),
    ];

    for (final gap in gaps) {
      await db.insert('skill_gaps', {
        'id': gap.id,
        'jobId': gap.jobId,
        'skillName': gap.skillName,
        'status': gap.status.name,
        'priority': gap.priority.name,
        'data': jsonEncode(gap.toJson()),
      });
    }

    // 5. Evidence Items
    final evidenceList = [
      const EvidenceItem(
        id: 'ev-1',
        requirementId: 'req-flutter',
        requirementTitle: 'Flutter & Dart Mobile Development',
        candidateQuote:
            'Architected and deployed 2 client Flutter applications on Google Play Store and Apple App Store.',
        confidence: EvidenceConfidence.high,
        explanation: 'Direct evidence of commercial Flutter deployment.',
      ),
      const EvidenceItem(
        id: 'ev-2',
        requirementId: 'req-rest-sqlite',
        requirementTitle: 'REST APIs & SQLite Caching',
        candidateQuote:
            'Integrated Dio REST client with Riverpod state management for dynamic real-time data caching.',
        confidence: EvidenceConfidence.high,
        explanation: 'Direct match for Dio REST API and SQLite caching requirements.',
      ),
      const EvidenceItem(
        id: 'ev-3',
        requirementId: 'req-aws-deploy',
        requirementTitle: 'AWS Deployment & Infrastructure',
        candidateQuote: 'AWS Certified Cloud Practitioner mentioned under Certifications.',
        confidence: EvidenceConfidence.medium,
        explanation:
          'Certification exists, but lacks hands-on production deployment experience.',
      ),
      const EvidenceItem(
        id: 'ev-4',
        requirementId: 'req-k8s',
        requirementTitle: 'Kubernetes & Container Orchestration',
        candidateQuote: 'No explicit evidence found.',
        confidence: EvidenceConfidence.none,
        explanation: 'Candidate resume does not mention Kubernetes or container tools.',
      ),
    ];

    for (final item in evidenceList) {
      await db.insert('evidence_items', {
        'id': item.id,
        'requirementId': item.requirementId,
        'confidence': item.confidence.name,
        'data': jsonEncode(item.toJson()),
      });
    }

    // 6. Resume Suggestions & Truth Guard Flags
    final suggestions = [
      const ResumeSuggestion(
        id: 'sug-1',
        jobId: demoJobId,
        originalBullet: 'Worked on a mobile application using Flutter.',
        suggestedBullet:
            'Developed responsive Flutter mobile interfaces using Dart and Riverpod state management, optimizing local SQLite database sync for offline resilience.',
        whyItChanged:
            'Emphasizes specific technical stack (Riverpod, SQLite) and matches target job requirements.',
        matchedRequirement: 'Flutter & Dart Mobile Development',
        status: SuggestionStatus.accepted,
        truthGuardFlags: [],
      ),
      const ResumeSuggestion(
        id: 'sug-2',
        jobId: demoJobId,
        originalBullet: 'Built API connections for mobile app.',
        suggestedBullet:
            'Integrated high-performance REST APIs using Dio client, reducing production network latency by 40% across iOS and Android.',
        whyItChanged: 'Added specific network impact metric.',
        matchedRequirement: 'REST APIs & SQLite Caching',
        status: SuggestionStatus.pending,
        truthGuardFlags: [
          TruthGuardFlag(
            title: 'Potential Unsupported Metric',
            description: '"reducing production network latency by 40%"',
            reason: 'No evidence of this exact 40% metric exists in your source resume.',
          ),
        ],
      ),
    ];

    for (final sug in suggestions) {
      await db.insert('resume_suggestions', {
        'id': sug.id,
        'jobId': sug.jobId,
        'status': sug.status.name,
        'data': jsonEncode(sug.toJson()),
      });
    }

    // 7. Mock Interview Session
    final interviewSession = InterviewSession(
      id: 'session-demo-1',
      jobId: demoJobId,
      jobTitle: 'Mobile Application Developer',
      mode: InterviewMode.quick,
      totalQuestions: 5,
      questions: const [
        InterviewQuestion(
          id: 'q-1',
          index: 1,
          text:
              'Your resume mentions a Flutter app with SQLite caching. Tell me how you structured state management and local data sync.',
          category: 'Technical',
          userAnswer:
              'I used Riverpod for state management. When an API call is made using Dio, the response is saved into the local SQLite database via sqflite. If the device goes offline, Riverpod providers automatically fallback to reading from SQLite.',
          evaluation: InterviewEvaluation(
            questionId: 'q-1',
            overallScore: 84,
            relevanceScore: 92,
            specificityScore: 78,
            technicalDepthScore: 86,
            structureScore: 80,
            starAnalysis: {
              'Situation': 'Building an offline-first mobile app using Flutter.',
              'Task': 'Ensure seamless data synchronization between REST APIs and local storage.',
              'Action': 'Used Dio REST client, Riverpod providers, and SQLite fallback mechanism.',
              'Result': 'Application maintains offline readability and reliable UI state.'
            },
            whatWorked: [
              'Clear technical flow explanation (Dio -> Riverpod -> SQLite).',
              'Directly answered how offline fallback was implemented.'
            ],
            whatWasWeak: [
              'Could add specific metrics on database write latency or error handling.'
            ],
            betterStructure:
              'Quantify database performance: "Reduced offline launch time to <100ms by indexing foreign key columns in SQLite."',
            suggestedFollowUp:
              'How did you handle conflict resolution when sync resumes after coming back online?',
          ),
        ),
      ],
      averageScore: 84,
      isCompleted: false,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    );

    await db.insert('interview_sessions', {
      'id': interviewSession.id,
      'jobId': interviewSession.jobId,
      'mode': interviewSession.mode.name,
      'data': jsonEncode(interviewSession.toJson()),
      'createdAt': interviewSession.createdAt.toIso8601String(),
    });

    // 8. Application Tracker
    final appTrack = ApplicationTrack(
      id: 'app-techcorp',
      jobId: demoJobId,
      jobTitle: 'Mobile Application Developer',
      companyName: 'TechCorp Solutions',
      stage: ApplicationStage.recruiterScreen,
      notes: 'Passed initial resume screen. Recruiter call scheduled for Friday at 2 PM.',
      appliedDate: DateTime.now().subtract(const Duration(days: 5)),
      followUpDate: DateTime.now().add(const Duration(days: 2)),
    );

    await db.insert('applications', {
      'id': appTrack.id,
      'jobId': appTrack.jobId,
      'stage': appTrack.stage.name,
      'data': jsonEncode(appTrack.toJson()),
      'appliedDate': appTrack.appliedDate.toIso8601String(),
    });

    // 9. Progress Snapshots
    final progressSnapshots = [
      {'week': 'Week 1', 'score': 61},
      {'week': 'Week 2', 'score': 67},
      {'week': 'Week 3', 'score': 74},
      {'week': 'Week 4', 'score': 78},
    ];

    for (final snap in progressSnapshots) {
      await db.insert('progress_snapshots', {
        'id': 'snap-${snap['week']}',
        'userId': demoUserId,
        'weekLabel': snap['week'] as String,
        'hireabilityScore': snap['score'] as int,
        'data': jsonEncode(snap),
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    // 10. AI Telemetry Logs
    await db.insert('ai_observability_logs', {
      'id': 'log-1',
      'requestType': 'Job Analysis & Evidence Mapping',
      'latencyMs': 420,
      'tokensUsed': 1250,
      'costEstimate': 0.0025,
      'status': 'SUCCESS',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
