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
import '../local/database_helper.dart';
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
    if (apiKey == null || apiKey!.isEmpty) {
      return _fallback.extractEvidence(candidate, job);
    }
    try {
      final prompt = '''
You are an Evidence Extraction AI for ATS resume screening. Match candidate experience against job requirements.
Return structured JSON:
{
  "evidence": [
    {
      "requirementId": "req-id",
      "requirementTitle": "Requirement Title",
      "candidateQuote": "Exact bullet quote from candidate experience or 'No explicit evidence found.'",
      "confidence": "HIGH", // HIGH, MEDIUM, LOW, or NONE
      "explanation": "Why this rating was given"
    }
  ]
}

Candidate Experience Bullets:
${candidate.experience.map((e) => (e['bullets'] as List<dynamic>? ?? []).join('\n')).join('\n')}

Job Requirements:
${job.requirements.map((r) => '${r.id}: ${r.title} (${r.category})').join('\n')}
''';

      final jsonRes = await _callOpenAiJson(prompt, requestType: 'Evidence Extraction');
      if (jsonRes != null && jsonRes['evidence'] != null) {
        final list = (jsonRes['evidence'] as List<dynamic>).map((item) {
          final confStr = (item['confidence'] as String? ?? 'NONE').toUpperCase();
          final conf = EvidenceConfidence.values.firstWhere(
            (c) => c.name.toUpperCase() == confStr,
            orElse: () => EvidenceConfidence.none,
          );
          return EvidenceItem(
            id: _uuid.v4(),
            requirementId: item['requirementId'] ?? '',
            requirementTitle: item['requirementTitle'] ?? '',
            candidateQuote: item['candidateQuote'] ?? 'No explicit evidence found.',
            confidence: conf,
            explanation: item['explanation'] ?? 'Analyzed by live AI engine.',
          );
        }).toList();

        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return _fallback.extractEvidence(candidate, job);
  }

  @override
  Future<List<SkillGap>> analyzeSkillGaps(CandidateProfile candidate, Job job, List<EvidenceItem> evidence) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return _fallback.analyzeSkillGaps(candidate, job, evidence);
    }
    try {
      final prompt = '''
You are a Skill Gap Priority Algorithm AI. Analyze missing and partial skill evidence for candidate targeting ${job.title}.
Return JSON:
{
  "gaps": [
    {
      "skillName": "Skill Name",
      "status": "missing", // missing, partial, or strong
      "priority": "critical", // critical, high, medium, or low
      "currentEvidence": "Summary of current evidence",
      "missingDetails": "What specific experience is missing",
      "whyItMatters": "Why this role requires it",
      "recommendedAction": "Actionable evidence building step",
      "priorityScore": 85 // 0-100 score
    }
  ]
}

Candidate Skills: ${candidate.skills.join(', ')}
Evidence Map:
${evidence.map((e) => '${e.requirementTitle}: [${e.confidence.name}] ${e.candidateQuote}').join('\n')}
''';

      final jsonRes = await _callOpenAiJson(prompt, requestType: 'Skill Gap Analysis');
      if (jsonRes != null && jsonRes['gaps'] != null) {
        final list = (jsonRes['gaps'] as List<dynamic>).map((g) {
          final statusStr = (g['status'] as String? ?? 'missing').toLowerCase();
          final status = GapMatchStatus.values.firstWhere(
            (s) => s.name.toLowerCase() == statusStr,
            orElse: () => GapMatchStatus.missing,
          );
          final priorityStr = (g['priority'] as String? ?? 'medium').toLowerCase();
          final priority = GapPriority.values.firstWhere(
            (p) => p.name.toLowerCase() == priorityStr,
            orElse: () => GapPriority.medium,
          );

          return SkillGap(
            id: _uuid.v4(),
            jobId: job.id,
            skillName: g['skillName'] ?? 'Target Skill',
            status: status,
            priority: priority,
            currentEvidence: g['currentEvidence'] ?? 'No evidence.',
            missingDetails: g['missingDetails'] ?? 'Missing specific experience.',
            whyItMatters: g['whyItMatters'] ?? 'Important requirement for the target role.',
            recommendedAction: g['recommendedAction'] ?? 'Build portfolio project evidence.',
            priorityScore: (g['priorityScore'] as num?)?.toInt() ?? 50,
          );
        }).toList();

        list.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return _fallback.analyzeSkillGaps(candidate, job, evidence);
  }

  @override
  Future<List<ResumeSuggestion>> optimizeResume(CandidateProfile candidate, Job job) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return _fallback.optimizeResume(candidate, job);
    }
    try {
      final prompt = '''
You are a Resume Optimizer AI. Optimize resume bullet points for candidate targeting ${job.title} at ${job.company}.
Return JSON:
{
  "suggestions": [
    {
      "originalBullet": "Original candidate bullet",
      "suggestedBullet": "Action-oriented improved bullet matching job requirement",
      "whyItChanged": "Explanation of improvement",
      "matchedRequirement": "Requirement matched",
      "truthGuardFlags": [
        {
          "title": "Warning title if quantitative claim was inferred",
          "description": "Quoted metric",
          "reason": "Why candidate needs to verify"
        }
      ]
    }
  ]
}

Candidate Bullets:
${candidate.experience.map((e) => (e['bullets'] as List<dynamic>? ?? []).join('\n')).join('\n')}

Job Requirements: ${job.requirements.map((r) => r.title).join(', ')}
''';

      final jsonRes = await _callOpenAiJson(prompt, requestType: 'Resume Optimization');
      if (jsonRes != null && jsonRes['suggestions'] != null) {
        final list = (jsonRes['suggestions'] as List<dynamic>).map((s) {
          final flags = (s['truthGuardFlags'] as List<dynamic>? ?? []).map((f) {
            return TruthGuardFlag(
              title: f['title'] ?? 'Verification Warning',
              description: f['description'] ?? '',
              reason: f['reason'] ?? 'Verify metric accuracy.',
            );
          }).toList();

          return ResumeSuggestion(
            id: _uuid.v4(),
            jobId: job.id,
            originalBullet: s['originalBullet'] ?? 'Original bullet',
            suggestedBullet: s['suggestedBullet'] ?? 'Optimized bullet',
            whyItChanged: s['whyItChanged'] ?? 'Optimized for target job keywords.',
            matchedRequirement: s['matchedRequirement'] ?? 'Target Job Alignment',
            status: SuggestionStatus.pending,
            truthGuardFlags: flags,
          );
        }).toList();

        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return _fallback.optimizeResume(candidate, job);
  }

  @override
  Future<List<TruthGuardFlag>> validateResumeTruth(String originalBullet, String suggestedBullet, CandidateProfile profile) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return _fallback.validateResumeTruth(originalBullet, suggestedBullet, profile);
    }
    try {
      final prompt = '''
You are a Resume Truth Guard Verification AI. Check if the suggested bullet makes hallucinated claims or unsupported metrics not grounded in candidate profile.
Return JSON:
{
  "flags": [
    {
      "title": "Flag title",
      "description": "Unsupported metric or claim text",
      "reason": "Detailed rationale"
    }
  ]
}

Original Bullet: $originalBullet
Suggested Bullet: $suggestedBullet
Candidate Profile Skills: ${profile.skills.join(', ')}
''';

      final jsonRes = await _callOpenAiJson(prompt, requestType: 'Truth Guard Validation');
      if (jsonRes != null && jsonRes['flags'] != null) {
        final flags = (jsonRes['flags'] as List<dynamic>).map((f) {
          return TruthGuardFlag(
            title: f['title'] ?? 'Truth Guard Flag',
            description: f['description'] ?? '',
            reason: f['reason'] ?? 'Unverified metric or technology claim.',
          );
        }).toList();

        return flags;
      }
    } catch (_) {}
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

Candidate Skills: ${profile.skills.join(', ')}
Job Description: ${job.description}
''';

      final jsonRes = await _callOpenAiJson(prompt, requestType: 'Interview Generation');
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

      final jsonRes = await _callOpenAiJson(prompt, requestType: 'STAR Answer Evaluation');
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

  Future<Map<String, dynamic>?> _callOpenAiJson(String systemPrompt, {String requestType = 'AI Analysis'}) async {
    final stopwatch = Stopwatch()..start();
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
      stopwatch.stop();

      if (response.statusCode == 200 && response.data != null) {
        final content = response.data['choices'][0]['message']['content'] as String;
        final usage = response.data['usage'];
        final tokens = usage != null ? (usage['total_tokens'] as int? ?? 500) : 500;
        final cost = tokens * 0.000002;

        _safeLogTelemetry(
          requestType: requestType,
          latencyMs: stopwatch.elapsedMilliseconds,
          tokensUsed: tokens,
          costEstimate: cost,
          status: 'SUCCESS',
        );

        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      stopwatch.stop();
      _safeLogTelemetry(
        requestType: requestType,
        latencyMs: stopwatch.elapsedMilliseconds,
        tokensUsed: 0,
        costEstimate: 0.0,
        status: 'ERROR: ${e.toString()}',
      );
    }
    return null;
  }

  void _safeLogTelemetry({
    required String requestType,
    required int latencyMs,
    required int tokensUsed,
    required double costEstimate,
    required String status,
  }) {
    try {
      DatabaseHelper.instance.logAiRequest(
        requestType: requestType,
        latencyMs: latencyMs,
        tokensUsed: tokensUsed,
        costEstimate: costEstimate,
        status: status,
      ).catchError((_) {});
    } catch (_) {}
  }
}

