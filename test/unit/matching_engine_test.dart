import 'package:flutter_test/flutter_test.dart';
import 'package:hirelens/data/remote/fallback_ai_engine.dart';
import 'package:hirelens/domain/entities/candidate_profile.dart';
import 'package:hirelens/domain/entities/job.dart';
import 'package:hirelens/domain/entities/evidence.dart';
import 'package:hirelens/domain/entities/skill_gap.dart';

void main() {
  group('HireLens AI Engine & Priority Algorithm Evals', () {
    final engine = FallbackAiEngine();

    final candidate = const CandidateProfile(
      id: 'c-1',
      userId: 'u-1',
      fullName: 'Alex Morgan',
      currentRole: 'Flutter Developer',
      yearsExperience: 2,
      targetRole: 'Mobile Developer',
      targetIndustry: 'Software',
      location: 'Remote',
      workPreference: 'Hybrid',
      summary: 'Flutter mobile engineer',
      skills: ['Flutter', 'Dart', 'REST APIs', 'SQLite'],
      experience: [
        {
          'bullets': [
            'Architected and deployed 2 client Flutter applications using REST APIs and SQLite local caching.'
          ]
        }
      ],
      projects: [],
      education: [],
      certifications: [],
      technologies: ['Flutter', 'Dart', 'SQLite', 'REST APIs'],
    );

    final job = Job(
      id: 'j-1',
      userId: 'u-1',
      title: 'Mobile Application Developer',
      company: 'TechCorp',
      location: 'San Francisco, CA',
      employmentType: 'Full-time',
      description: 'Need Flutter, REST APIs, and AWS deployment experience.',
      applicationUrl: '',
      seniority: 'Mid-Level',
      minYearsExp: 2,
      requirements: const [
        JobRequirement(
          id: 'req-flutter',
          title: 'Flutter & Dart Mobile Development',
          category: 'must_have',
          rationale: 'Core framework',
          importance: 'HIGH',
        ),
        JobRequirement(
          id: 'req-aws',
          title: 'AWS Deployment & Infrastructure',
          category: 'preferred',
          rationale: 'Cloud infrastructure',
          importance: 'MEDIUM',
        ),
      ],
      createdAt: DateTime.now(),
    );

    test('Score Calculation generates transparent score between 0 and 100', () async {
      final score = await engine.calculateHireabilityScore(candidate, job);
      expect(score.overallScore, greaterThanOrEqualTo(50));
      expect(score.overallScore, lessThanOrEqualTo(100));
      expect(score.breakdowns, isNotEmpty);
    });

    test('Evidence Engine correctly extracts quotes with High vs None confidence', () async {
      final evidence = await engine.extractEvidence(candidate, job);
      expect(evidence.length, equals(2));

      final flutterEv = evidence.firstWhere((e) => e.requirementId == 'req-flutter');
      expect(flutterEv.confidence, equals(EvidenceConfidence.high));

      final awsEv = evidence.firstWhere((e) => e.requirementId == 'req-aws');
      expect(awsEv.confidence, equals(EvidenceConfidence.none));
    });

    test('Skill Gap Priority algorithm assigns Critical priority to missing evidence', () async {
      final evidence = await engine.extractEvidence(candidate, job);
      final gaps = await engine.analyzeSkillGaps(candidate, job, evidence);

      final awsGap = gaps.firstWhere((g) => g.skillName.contains('AWS'));
      expect(awsGap.status, equals(GapMatchStatus.missing));
      expect(awsGap.priority, equals(GapPriority.critical));
    });

    test('Truth Guard detects unsupported metric claims in generated resume bullets', () async {
      const orig = 'Worked on mobile app features using Flutter.';
      const suggestedWithMetric =
          'Developed Flutter app features, cutting API response latency by 50%.';

      final flags = await engine.validateResumeTruth(orig, suggestedWithMetric, candidate);
      expect(flags, isNotEmpty);
      expect(flags.first.title, contains('Invented Metric'));
    });
  });
}
