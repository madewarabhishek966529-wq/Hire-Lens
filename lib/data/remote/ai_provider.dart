import '../../domain/entities/candidate_profile.dart';
import '../../domain/entities/job.dart';
import '../../domain/entities/hireability_score.dart';
import '../../domain/entities/skill_gap.dart';
import '../../domain/entities/evidence.dart';
import '../../domain/entities/resume_suggestion.dart';
import '../../domain/entities/interview.dart';

abstract class AiProvider {
  /// Parses raw resume text or file into a structured candidate profile
  Future<CandidateProfile> parseResume(String rawText, {String? userId});

  /// Analyzes a job description text into structured job requirements
  Future<Job> analyzeJob(String title, String company, String jdText, {String? userId});

  /// Calculates a transparent 0-100 hireability score & breakdown
  Future<HireabilityScore> calculateHireabilityScore(CandidateProfile candidate, Job job);

  /// Maps candidate evidence to each job requirement
  Future<List<EvidenceItem>> extractEvidence(CandidateProfile candidate, Job job);

  /// Identifies skill gaps and prioritizes them based on importance & severity
  Future<List<SkillGap>> analyzeSkillGaps(CandidateProfile candidate, Job job, List<EvidenceItem> evidence);

  /// Generates job-tailored resume bullet improvements
  Future<List<ResumeSuggestion>> optimizeResume(CandidateProfile candidate, Job job);

  /// Runs Resume Truth Guard checks to detect unsupported metrics or fake claims
  Future<List<TruthGuardFlag>> validateResumeTruth(String originalBullet, String suggestedBullet, CandidateProfile profile);

  /// Generates role-specific mock interview questions
  Future<InterviewSession> generateInterviewSession(Job job, CandidateProfile profile, InterviewMode mode);

  /// Evaluates an interview answer using the STAR rubric
  Future<InterviewEvaluation> evaluateInterviewAnswer(String questionId, String questionText, String answerText);
}
