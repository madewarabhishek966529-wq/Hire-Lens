import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database_helper.dart';
import '../../data/local/demo_data_seeder.dart';
import '../../domain/entities/resume_suggestion.dart';
import 'job_provider.dart';

class ResumeOptimizerState {
  final List<ResumeSuggestion> suggestions;
  final bool isLoading;
  final String? errorMessage;

  const ResumeOptimizerState({
    this.suggestions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ResumeOptimizerState copyWith({
    List<ResumeSuggestion>? suggestions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ResumeOptimizerState(
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ResumeOptimizerNotifier extends StateNotifier<ResumeOptimizerState> {
  final Ref ref;

  ResumeOptimizerNotifier(this.ref) : super(const ResumeOptimizerState()) {
    loadSuggestions();
  }

  Future<void> loadSuggestions() async {
    state = state.copyWith(isLoading: true);
    try {
      final selectedJob = ref.read(jobProvider).selectedJob;
      final jobId = selectedJob?.id ?? DemoDataSeeder.demoJobId;
      final suggestions = await DatabaseHelper.instance.getResumeSuggestions(jobId);
      state = state.copyWith(
        suggestions: suggestions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateSuggestionStatus(String suggestionId, SuggestionStatus status) async {
    final list = state.suggestions.map((s) {
      if (s.id == suggestionId) {
        final updated = ResumeSuggestion(
          id: s.id,
          jobId: s.jobId,
          originalBullet: s.originalBullet,
          suggestedBullet: s.suggestedBullet,
          whyItChanged: s.whyItChanged,
          matchedRequirement: s.matchedRequirement,
          status: status,
          truthGuardFlags: s.truthGuardFlags,
        );
        DatabaseHelper.instance.updateResumeSuggestion(updated);
        return updated;
      }
      return s;
    }).toList();

    state = state.copyWith(suggestions: list);
  }
}

final resumeOptimizerProvider =
    StateNotifierProvider<ResumeOptimizerNotifier, ResumeOptimizerState>((ref) {
  return ResumeOptimizerNotifier(ref);
});
