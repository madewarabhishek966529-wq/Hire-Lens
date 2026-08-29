import 'package:dio/dio.dart';
import '../../domain/entities/candidate_profile.dart';
import '../../domain/entities/job.dart';
import '../../domain/entities/hireability_score.dart';
import '../../domain/entities/skill_gap.dart';
import '../../domain/entities/evidence.dart';
import '../../domain/entities/resume_suggestion.dart';
import '../../domain/entities/interview.dart';
import 'ai_provider.dart';
import 'fallback_ai_engine.dart';

class OpenAiProvider implements AiProvider {
  final Dio dio;
  final String? apiKey;
  final FallbackAiEngine _fallback = FallbackAiEngine();

  OpenAiProvider({required this.dio, this.apiKey});

  @override
  Future<CandidateProfile> parseResume(String rawText, {String? userId}) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return _fallback.parseResume(rawText, userId: userId);
    }
    try {
      // Live API call structure placeholder
      return await _fallback.parseResume(rawText, userId: userId);
    } catch (_) {
      return _fallback.parseResume(rawText, userId: userId);
    }
  }

  @override
  Future<Job> analyzeJob(String title, String company, String jdText, {String? userId}) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return _fallback.analyzeJob(title, company, jdText, userId: userId);
    }
    try {
      return await _fallback.analyzeJob(title, company, jdText, userId: userId);
    } catch (_) {
      return _fallback.analyzeJob(title, company, jdText, userId: userId);
    }
  }

  @override
  Future<HireabilityScore> calculateHireabilityScore(CandidateProfile candidate, Job job) async {
    return _fallback.calculateHireabilityScore(candidate, job);
  }

  @override
  Future<List<EvidenceItem>> extractEvidence(CandidateProfile candidate, Job job) async {
    return _fallback.extractEvidence(candidate, job);
  }

  @override
  Future<List<SkillGap>> analyzeSkillGaps(CandidateProfile candidate, Job job, List<EvidenceItem> evidence) async {
    return _fallback.analyzeSkillGaps(candidate, job, evidence);
  }

  @override
  Future<List<ResumeSuggestion>> optimizeResume(CandidateProfile candidate, Job job) async {
    return _fallback.optimizeResume(candidate, job);
  }

  @override
  Future<List<TruthGuardFlag>> validateResumeTruth(String originalBullet, String suggestedBullet, CandidateProfile profile) async {
    return _fallback.validateResumeTruth(originalBullet, suggestedBullet, profile);
  }

  @override
  Future<InterviewSession> generateInterviewSession(Job job, CandidateProfile profile, InterviewMode mode) async {
    return _fallback.generateInterviewSession(job, profile, mode);
  }

  @override
  Future<InterviewEvaluation> evaluateInterviewAnswer(String questionId, String questionText, String answerText) async {
    return _fallback.evaluateInterviewAnswer(questionId, questionText, answerText);
  }
}
