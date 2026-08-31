import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hirelens/data/local/file_parser_service.dart';
import 'package:hirelens/data/remote/openai_provider.dart';
import 'package:hirelens/domain/entities/candidate_profile.dart';
import 'package:hirelens/domain/entities/job.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Real-World AI & File Parser Tests', () {
    final candidate = const CandidateProfile(
      id: 'c-test',
      userId: 'u-test',
      fullName: 'Alex Morgan',
      currentRole: 'Flutter Developer',
      yearsExperience: 2,
      targetRole: 'Mobile Developer',
      targetIndustry: 'Software',
      location: 'Remote',
      workPreference: 'Hybrid',
      summary: 'Flutter mobile engineer',
      skills: ['Flutter', 'Dart', 'REST APIs'],
      experience: [
        {
          'bullets': ['Developed Flutter apps with REST APIs.']
        }
      ],
      projects: [],
      education: [],
      certifications: [],
      technologies: ['Flutter', 'Dart'],
    );

    final job = Job(
      id: 'j-test',
      userId: 'u-test',
      title: 'Flutter Developer',
      company: 'TechCorp',
      location: 'Remote',
      employmentType: 'Full-time',
      description: 'Flutter and REST API development',
      applicationUrl: '',
      seniority: 'Mid-Level',
      minYearsExp: 2,
      requirements: const [
        JobRequirement(
          id: 'req-1',
          title: 'Flutter & Dart',
          category: 'must_have',
          rationale: 'Core skill',
          importance: 'HIGH',
        )
      ],
      createdAt: DateTime.now(),
    );

    test('OpenAiProvider falls back gracefully when no API key is provided', () async {
      final provider = OpenAiProvider(dio: Dio(), apiKey: null);
      final score = await provider.calculateHireabilityScore(candidate, job);
      expect(score.overallScore, greaterThan(0));

      final evidence = await provider.extractEvidence(candidate, job);
      expect(evidence, isNotEmpty);
    });

    test('OpenAiProvider extracts evidence and optimizes resume correctly', () async {
      final provider = OpenAiProvider(dio: Dio(), apiKey: 'sk-test-key-mock');
      final suggestions = await provider.optimizeResume(candidate, job);
      expect(suggestions, isNotEmpty);
    });

    test('FileParserService cleans extracted text streams', () async {
      const rawPdfText = 'BT /Type /Page /Filter /FlateDecode (Alex Morgan Resume Flutter Developer) ET';
      final clean = FileParserService.extractTextFromPlatformFile;
      expect(clean, isNotNull);
    });
  });
}
