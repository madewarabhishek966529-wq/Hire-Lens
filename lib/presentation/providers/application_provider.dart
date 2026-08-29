import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database_helper.dart';
import '../../domain/entities/application.dart';

class ApplicationState {
  final List<ApplicationTrack> applications;
  final bool isLoading;

  const ApplicationState({this.applications = const [], this.isLoading = false});

  ApplicationState copyWith({List<ApplicationTrack>? applications, bool? isLoading}) {
    return ApplicationState(
      applications: applications ?? this.applications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ApplicationNotifier extends StateNotifier<ApplicationState> {
  ApplicationNotifier() : super(const ApplicationState()) {
    loadApplications();
  }

  Future<void> loadApplications() async {
    state = state.copyWith(isLoading: true);
    final list = await DatabaseHelper.instance.getApplications();
    state = state.copyWith(applications: list, isLoading: false);
  }

  Future<void> updateStage(String appId, ApplicationStage stage) async {
    final list = state.applications.map((app) {
      if (app.id == appId) {
        final updated = ApplicationTrack(
          id: app.id,
          jobId: app.jobId,
          jobTitle: app.jobTitle,
          companyName: app.companyName,
          stage: stage,
          notes: app.notes,
          appliedDate: app.appliedDate,
          followUpDate: app.followUpDate,
        );
        DatabaseHelper.instance.saveApplication(updated);
        return updated;
      }
      return app;
    }).toList();
    state = state.copyWith(applications: list);
  }
}

final applicationProvider =
    StateNotifierProvider<ApplicationNotifier, ApplicationState>((ref) {
  return ApplicationNotifier();
});
