import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database_helper.dart';
import '../../data/local/demo_data_seeder.dart';
import '../../data/remote/fallback_ai_engine.dart';
import '../../domain/entities/job.dart';

class JobState {
  final List<Job> jobs;
  final Job? selectedJob;
  final bool isLoading;
  final String? errorMessage;

  const JobState({
    required this.jobs,
    this.selectedJob,
    this.isLoading = false,
    this.errorMessage,
  });

  JobState copyWith({
    List<Job>? jobs,
    Job? selectedJob,
    bool? isLoading,
    String? errorMessage,
  }) {
    return JobState(
      jobs: jobs ?? this.jobs,
      selectedJob: selectedJob ?? this.selectedJob,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class JobNotifier extends StateNotifier<JobState> {
  JobNotifier() : super(const JobState(jobs: [])) {
    loadJobs();
  }

  Future<void> loadJobs() async {
    state = state.copyWith(isLoading: true);
    try {
      final jobs = await DatabaseHelper.instance.getJobs(DemoDataSeeder.demoUserId);
      final selected = jobs.isNotEmpty ? jobs.first : null;
      state = state.copyWith(
        jobs: jobs,
        selectedJob: selected,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> selectJob(String jobId) async {
    final job = state.jobs.firstWhere((j) => j.id == jobId, orElse: () => state.jobs.first);
    state = state.copyWith(selectedJob: job);
  }

  Future<Job> createJobFromDescription({
    required String title,
    required String company,
    required String jdText,
  }) async {
    state = state.copyWith(isLoading: true);
    final engine = FallbackAiEngine();
    final newJob = await engine.analyzeJob(title, company, jdText, userId: DemoDataSeeder.demoUserId);
    await DatabaseHelper.instance.saveJob(newJob);
    
    final updatedList = [newJob, ...state.jobs];
    state = state.copyWith(
      jobs: updatedList,
      selectedJob: newJob,
      isLoading: false,
    );
    return newJob;
  }
}

final jobProvider = StateNotifierProvider<JobNotifier, JobState>((ref) {
  return JobNotifier();
});
