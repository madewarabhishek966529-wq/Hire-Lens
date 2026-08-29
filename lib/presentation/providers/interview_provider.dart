import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database_helper.dart';
import '../../data/local/demo_data_seeder.dart';
import '../../data/remote/fallback_ai_engine.dart';
import '../../domain/entities/interview.dart';
import '../../domain/entities/job.dart';
import 'job_provider.dart';

class InterviewState {
  final List<InterviewSession> sessions;
  final InterviewSession? activeSession;
  final int currentQuestionIndex;
  final bool isEvaluating;
  final String? errorMessage;

  const InterviewState({
    this.sessions = const [],
    this.activeSession,
    this.currentQuestionIndex = 0,
    this.isEvaluating = false,
    this.errorMessage,
  });

  InterviewState copyWith({
    List<InterviewSession>? sessions,
    InterviewSession? activeSession,
    int? currentQuestionIndex,
    bool? isEvaluating,
    String? errorMessage,
  }) {
    return InterviewState(
      sessions: sessions ?? this.sessions,
      activeSession: activeSession ?? this.activeSession,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isEvaluating: isEvaluating ?? this.isEvaluating,
      errorMessage: errorMessage,
    );
  }
}

class InterviewNotifier extends StateNotifier<InterviewState> {
  final Ref ref;

  InterviewNotifier(this.ref) : super(const InterviewState()) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    try {
      final selectedJob = ref.read(jobProvider).selectedJob;
      final jobId = selectedJob?.id ?? DemoDataSeeder.demoJobId;
      final sessions = await DatabaseHelper.instance.getInterviewSessions(jobId);
      state = state.copyWith(
        sessions: sessions,
        activeSession: sessions.isNotEmpty ? sessions.first : null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> startNewSession(InterviewMode mode) async {
    final selectedJob = ref.read(jobProvider).selectedJob;
    final jobId = selectedJob?.id ?? DemoDataSeeder.demoJobId;
    final jobTitle = selectedJob?.title ?? 'Mobile Application Developer';

    final engine = FallbackAiEngine();
    // Generate questions
    final session = await engine.generateInterviewSession(
      selectedJob ??
          Job(
            id: jobId,
            userId: DemoDataSeeder.demoUserId,
            title: jobTitle,
            company: 'TechCorp',
            location: 'Remote',
            employmentType: 'Full-time',
            description: '',
            applicationUrl: '',
            seniority: 'Mid-Level',
            minYearsExp: 2,
            requirements: [],
            createdAt: DateTime.now(),
          ),
      ref.read(jobProvider).selectedJob != null
          ? (await DatabaseHelper.instance.getProfile(DemoDataSeeder.demoUserId))!
          : (await DatabaseHelper.instance.getProfile(DemoDataSeeder.demoUserId))!,
      mode,
    );

    await DatabaseHelper.instance.saveInterviewSession(session);
    state = state.copyWith(
      sessions: [session, ...state.sessions],
      activeSession: session,
      currentQuestionIndex: 0,
    );
  }

  Future<void> submitAnswer(String answerText) async {
    final session = state.activeSession;
    if (session == null || session.questions.isEmpty) return;

    state = state.copyWith(isEvaluating: true);
    final currentQ = session.questions[state.currentQuestionIndex];
    final engine = FallbackAiEngine();

    final evaluation = await engine.evaluateInterviewAnswer(
      currentQ.id,
      currentQ.text,
      answerText,
    );

    final updatedQ = currentQ.copyWith(
      userAnswer: answerText,
      evaluation: evaluation,
    );

    final updatedQuestions = List<InterviewQuestion>.from(session.questions);
    updatedQuestions[state.currentQuestionIndex] = updatedQ;

    final updatedSession = InterviewSession(
      id: session.id,
      jobId: session.jobId,
      jobTitle: session.jobTitle,
      mode: session.mode,
      totalQuestions: session.totalQuestions,
      questions: updatedQuestions,
      averageScore: evaluation.overallScore,
      isCompleted: state.currentQuestionIndex == session.questions.length - 1,
      createdAt: session.createdAt,
    );

    await DatabaseHelper.instance.saveInterviewSession(updatedSession);
    state = state.copyWith(
      activeSession: updatedSession,
      isEvaluating: false,
    );
  }

  void nextQuestion() {
    final session = state.activeSession;
    if (session != null && state.currentQuestionIndex < session.questions.length - 1) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
    }
  }
}

final interviewProvider = StateNotifierProvider<InterviewNotifier, InterviewState>((ref) {
  return InterviewNotifier(ref);
});
