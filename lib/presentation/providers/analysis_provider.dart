import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database_helper.dart';
import '../../data/local/demo_data_seeder.dart';
import '../../domain/entities/evidence.dart';
import '../../domain/entities/hireability_score.dart';
import '../../domain/entities/job.dart';
import '../../domain/entities/skill_gap.dart';
import 'ai_service_provider.dart';
import 'auth_provider.dart';
import 'job_provider.dart';

class AnalysisState {
  final HireabilityScore? score;
  final List<SkillGap> skillGaps;
  final List<EvidenceItem> evidenceItems;
  final bool isLoading;
  final String? errorMessage;

  const AnalysisState({
    this.score,
    this.skillGaps = const [],
    this.evidenceItems = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AnalysisState copyWith({
    HireabilityScore? score,
    List<SkillGap>? skillGaps,
    List<EvidenceItem>? evidenceItems,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AnalysisState(
      score: score ?? this.score,
      skillGaps: skillGaps ?? this.skillGaps,
      evidenceItems: evidenceItems ?? this.evidenceItems,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AnalysisNotifier extends StateNotifier<AnalysisState> {
  final Ref ref;

  AnalysisNotifier(this.ref) : super(const AnalysisState()) {
    loadAnalysis();
  }

  Future<void> loadAnalysis() async {
    state = state.copyWith(isLoading: true);
    try {
      final selectedJob = ref.read(jobProvider).selectedJob;
      final jobId = selectedJob?.id ?? DemoDataSeeder.demoJobId;

      final score = await DatabaseHelper.instance.getHireabilityScore(jobId);
      final gaps = await DatabaseHelper.instance.getSkillGaps(jobId);
      final evidence = await DatabaseHelper.instance.getEvidenceForRequirements([]);

      state = state.copyWith(
        score: score,
        skillGaps: gaps,
        evidenceItems: evidence,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> runFullAnalysisForJob(Job job) async {
    state = state.copyWith(isLoading: true);
    final profile = ref.read(authProvider).profile;
    final engine = ref.read(aiServiceProvider);

    if (profile != null) {
      final score = await engine.calculateHireabilityScore(profile, job);
      final evidence = await engine.extractEvidence(profile, job);
      final gaps = await engine.analyzeSkillGaps(profile, job, evidence);

      await DatabaseHelper.instance.saveHireabilityScore(score);
      await DatabaseHelper.instance.saveEvidenceItems(evidence);
      await DatabaseHelper.instance.saveSkillGaps(gaps);

      state = state.copyWith(
        score: score,
        evidenceItems: evidence,
        skillGaps: gaps,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: 'No candidate profile found.');
    }
  }
}

final analysisProvider = StateNotifierProvider<AnalysisNotifier, AnalysisState>((ref) {
  return AnalysisNotifier(ref);
});
