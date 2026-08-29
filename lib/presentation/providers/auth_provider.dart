import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database_helper.dart';
import '../../data/local/demo_data_seeder.dart';
import '../../domain/entities/candidate_profile.dart';

enum AuthStatus { unauthenticated, authenticated, onboarding, demo }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final CandidateProfile? profile;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.userId,
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    CandidateProfile? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
      : super(const AuthState(status: AuthStatus.demo, userId: DemoDataSeeder.demoUserId)) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await DatabaseHelper.instance.getProfile(DemoDataSeeder.demoUserId);
      if (profile != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          userId: DemoDataSeeder.demoUserId,
          profile: profile,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.demo,
          userId: DemoDataSeeder.demoUserId,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loginDemoMode() async {
    state = state.copyWith(isLoading: true);
    final profile = await DatabaseHelper.instance.getProfile(DemoDataSeeder.demoUserId);
    state = state.copyWith(
      status: AuthStatus.demo,
      userId: DemoDataSeeder.demoUserId,
      profile: profile,
      isLoading: false,
    );
  }

  Future<void> loginEmail(String email, String password) async {
    state = state.copyWith(isLoading: true);
    // Authenticate and load profile
    final profile = await DatabaseHelper.instance.getProfile(DemoDataSeeder.demoUserId);
    state = state.copyWith(
      status: AuthStatus.authenticated,
      userId: DemoDataSeeder.demoUserId,
      profile: profile,
      isLoading: false,
    );
  }

  Future<void> saveOnboardingProfile(CandidateProfile profile) async {
    state = state.copyWith(isLoading: true);
    await DatabaseHelper.instance.saveProfile(profile);
    state = state.copyWith(
      status: AuthStatus.authenticated,
      profile: profile,
      isLoading: false,
    );
  }

  Future<void> logout() async {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
