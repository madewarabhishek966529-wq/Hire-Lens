import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

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
  final String model;
  final FallbackAiEngine _fallback = FallbackAiEngine();
  final _uuid = const Uuid();

  OpenAiProvider({
    required this.dio,
    this.apiKey,
    this.model = 'gpt-4o-mini',
  });

  @override
  Future<CandidateProfile> parseResume(String rawText, {String? userId}) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return _fallback.parseResume(rawText, userId: userId);
    }
    try {
      final prompt = '''
You are an expert ATS and Resume Parsing AI. Analyze this candidate resume text and return structured JSON matching this schema:
{
  "fullName": "Candidate Name",
  "currentRole": "Current Job Title",
  "yearsExperience": 3,
  "targetRole": "Target Role",
  "summary": "Brief summary",
  "skills": ["Skill1", "Skill2"],
  "experience": [{"title": "Role", "company": "Company", "duration": "Dates", "bullets": ["Bullet 1"]}],
  "projects": [{"name": "Project Name", "tech": "Tech used", "description": "Desc"}],
  "education": [{"degree": "Degree", "institution": "School", "year": "2023"}],
  "certifications": ["Cert 1"],
  "technologies": ["Tech 1", "Tech 2"]
}

Resume Text:
$rawText
''';

      final jsonRes = await _callOpenAiJson(prompt);
      if (jsonRes != null) {
        return CandidateProfile(
          id: _uuid.v4(),
          userId: userId ?? 'user-current',
          fullName: jsonRes['fullName'] ?? 'Candidate Name',
          currentRole: jsonRes['currentRole'] ?? 'Software Engineer',
          yearsExperience: (jsonRes['yearsExperience'] as num?)?.toInt() ?? 2,
          targetRole: jsonRes['targetRole'] ?? 'Software Developer',
          targetIndustry: 'Technology',
          location: 'Remote',
          workPreference: 'Full-time',
          summary: jsonRes['summary'] ?? rawText.substring(0, 150),
          skills: List<String>.from(jsonRes['skills'] ?? []),
          experience: List<Map<String, dynamic>>.from(jsonRes['experience'] ?? []),
          projects: List<Map<String, dynamic>>.from(jsonRes['projects'] ?? []),
          education: List<Map<String, dynamic>>.from(jsonRes['education'] ?? []),
          certifications: List<String>.from(jsonRes['certifications'] ?? []),
          technologies: List<String>.from(jsonRes['technologies'] ?? []),
        );
      }
    } catch (_) {}
    return _fallback.parseResume(rawText, userId: userId);
  }

  @override
  Future<Job> analyzeJob(String title, String company, String jdText, {String? userId}) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return _fallback.analyzeJob(title, company, jdText, userId: userId);
    }
    try {
      final prompt = '''
You are a Senior Technical Recruiter and Job Description Analyzer. Extract key requirements from this job description into structured JSON:
{
  "seniority": "Mid-Level",
  "minYearsExp": 3,
  "requirements": [
    {
      "id": "req-1",
      "title": "Requirement title",
      "category": "must_have", // must_have, preferred, or nice_to_have
      "rationale": "Why this requirement was classified this way",
      "importance": "HIGH" // HIGH, MEDIUM, or LOW
    }
  ]
}

Job Title: $title
Company: $company
Job Description:
$jdText
''';

      final jsonRes = await _callOpenAiJson(prompt);
      if (jsonRes != null && jsonRes['requirements'] != null) {
        final reqsList = (jsonRes['requirements'] as List<dynamic>)
            .map((r) => JobRequirement.fromJson(Map<String, dynamic>.from(r)))
            .toList();

        return Job(
          id: _uuid.v4(),
          userId: userId ?? 'user-current',
          title: title.isNotEmpty ? title : 'Target Role',
          company: company.isNotEmpty ? company : 'Target Company',
          location: 'Remote',
          employmentType: 'Full-time',
          description: jdText,
          applicationUrl: '',
          seniority: jsonRes['seniority'] ?? 'Mid-Level',
          minYearsExp: (jsonRes['minYearsExp'] as num?)?.toInt() ?? 2,
          requirements: reqsList,
          createdAt: DateTime.now(),
        );
      }
    } catch (_) {}
    return _fallback.analyzeJob(title, company, jdText, userId: userId);
  }

  @override
  Future<HireabilityScore> calculateHireabilityScore(CandidateProfile candidate, Job job) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return _fallback.calculateHireabilityScore(candidate, job);
    }
    try {
      final prompt = '''
Analyze candidate profile against target job description. Output transparent 0-100 hireability score JSON:
{
  "overallScore": 76,
  "scoreChange": 5,
  "technicalSkillsScore": 84,
  "experienceRelevanceScore": 78,
  "projectEvidenceScore": 65,
  "resumeQualityScore": 80,
  "keywordAlignmentScore": 85,
  "seniorityAlignmentScore": 70,
  "summaryRationale": "Detailed summary explanation of score fit"
}

Candidate Skills: ${candidate.skills.join(', ')}
Job Title: ${job.title}
Requirements: ${job.requirements.map((r) => r.title).join('; ')}
''';
      final jsonRes = await _callOpenAiJson(prompt);
      if (jsonRes != null && jsonRes['overallScore'] != null) {
        final int overall = (jsonRes['overallScore'] as num).toInt();
        return HireabilityScore(
          id: _uuid.v4(),
          jobId: job.id,
          overallScore: overall,
          scoreChange: (jsonRes['scoreChange'] as num?)?.toInt() ?? 5,
          technicalSkillsScore: (jsonRes['technicalSkillsScore'] as num?)?.toInt() ?? overall,
          experienceRelevanceScore: (jsonRes['experienceRelevanceScore'] as num?)?.toInt() ?? overall,
          projectEvidenceScore: (jsonRes['projectEvidenceScore'] as num?)?.toInt() ?? overall,
          resumeQualityScore: (jsonRes['resumeQualityScore'] as num?)?.toInt() ?? overall,
          keywordAlignmentScore: (jsonRes['keywordAlignmentScore'] as num?)?.toInt() ?? overall,
          seniorityAlignmentScore: (jsonRes['seniorityAlignmentScore'] as num?)?.toInt() ?? overall,
          breakdowns: [
            ScoreCategoryBreakdown(
              categoryName: 'Technical Skills',
              score: (jsonRes['technicalSkillsScore'] as num?)?.toInt() ?? overall,
              explanation: 'Calculated from live AI evaluation of candidate skill match.',
              positiveFactors: ['Matched core job requirements'],
              negativeFactors: ['Missing cloud infrastructure proof'],
            )
          ],
          summaryRationale: jsonRes['summaryRationale'] ??
              'Estimated job-fit score based on live AI match analysis.',
          calculatedAt: DateTime.now(),
        );
      }
    } catch (_) {}
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
    if (apiKey == null || apiKey!.isEmpty) {
      return _fallback.generateInterviewSession(job, profile, mode);
    }
    try {
      final prompt = '''
Generate 3 tailored interview questions for candidate targeting ${job.title} at ${job.company}.
Output JSON format:
{
  "questions": [
    {"index": 1, "text": "Question 1 text?", "category": "Technical"},
    {"index": 2, "text": "Question 2 text?", "category": "Behavioral"},
    {"index": 3, "text": "Question 3 text?", "category": "Project Experience"}
  ]
}

Candidate Skills: ${candidate.skills.join(', ')}
Job Description: ${job.description}
''';

      final jsonRes = await _callOpenAiJson(prompt);
      if (jsonRes != null && jsonRes['questions'] != null) {
        final qList = (jsonRes['questions'] as List<dynamic>).map((q) {
          return InterviewQuestion(
            id: _uuid.v4(),
            index: (q['index'] as num?)?.toInt() ?? 1,
            text: q['text'] ?? 'Tell me about your experience.',
            category: q['category'] ?? 'Technical',
          );
        }).toList();

        return InterviewSession(
          id: _uuid.v4(),
          jobId: job.id,
          jobTitle: job.title,
          mode: mode,
          totalQuestions: qList.length,
          questions: qList,
          averageScore: 0,
          isCompleted: false,
          createdAt: DateTime.now(),
        );
      }
    } catch (_) {}
    return _fallback.generateInterviewSession(job, profile, mode);
  }

  @override
  Future<InterviewEvaluation> evaluateInterviewAnswer(String questionId, String questionText, String answerText) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return _fallback.evaluateInterviewAnswer(questionId, questionText, answerText);
    }
    try {
      final prompt = '''
Evaluate candidate interview answer using the STAR framework. Return JSON:
{
  "overallScore": 82,
  "relevanceScore": 88,
  "specificityScore": 75,
  "technicalDepthScore": 84,
  "structureScore": 80,
  "starAnalysis": {
    "Situation": "Candidate situation",
    "Task": "Task identified",
    "Action": "Action taken",
    "Result": "Outcome achieved"
  },
  "whatWorked": ["Worked point 1", "Worked point 2"],
  "whatWasWeak": ["Weakness point 1"],
  "betterStructure": "How to structure answer better",
  "suggestedFollowUp": "Follow up question?"
}

Question: $questionText
Candidate Answer: $answerText
''';

      final jsonRes = await _callOpenAiJson(prompt);
      if (jsonRes != null && jsonRes['overallScore'] != null) {
        return InterviewEvaluation(
          questionId: questionId,
          overallScore: (jsonRes['overallScore'] as num).toInt(),
          relevanceScore: (jsonRes['relevanceScore'] as num?)?.toInt() ?? 80,
          specificityScore: (jsonRes['specificityScore'] as num?)?.toInt() ?? 75,
          technicalDepthScore: (jsonRes['technicalDepthScore'] as num?)?.toInt() ?? 80,
          structureScore: (jsonRes['structureScore'] as num?)?.toInt() ?? 80,
          starAnalysis: Map<String, String>.from(jsonRes['starAnalysis'] ?? {}),
          whatWorked: List<String>.from(jsonRes['whatWorked'] ?? []),
          whatWasWeak: List<String>.from(jsonRes['whatWasWeak'] ?? []),
          betterStructure: jsonRes['betterStructure'] ?? 'Structure answer with STAR method.',
          suggestedFollowUp: jsonRes['suggestedFollowUp'] ?? 'Can you quantify the latency reduction?',
        );
      }
    } catch (_) {}
    return _fallback.evaluateInterviewAnswer(questionId, questionText, answerText);
  }

  Future<Map<String, dynamic>?> _callOpenAiJson(String systemPrompt) async {
    try {
      final response = await dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model,
          'messages': [
            {'role': 'user', 'content': systemPrompt}
          ],
          'response_format': {'type': 'json_object'},
          'temperature': 0.2,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final content = response.data['choices'][0]['message']['content'] as String;
        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      // Fallback on error
    }
    return null;
  }
}
