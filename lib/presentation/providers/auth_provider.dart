import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const _prefUserId = 'hirelens_active_user_id';
  static const _prefAuthStatus = 'hirelens_auth_status';

  AuthNotifier()
      : super(const AuthState(status: AuthStatus.demo, userId: DemoDataSeeder.demoUserId)) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString(_prefUserId) ?? DemoDataSeeder.demoUserId;
      final savedStatusStr = prefs.getString(_prefAuthStatus) ?? AuthStatus.demo.name;

      final status = AuthStatus.values.firstWhere(
        (s) => s.name == savedStatusStr,
        orElse: () => AuthStatus.demo,
      );

      final profile = await DatabaseHelper.instance.getProfile(savedUserId);
      if (profile != null) {
        state = state.copyWith(
          status: status,
          userId: savedUserId,
          profile: profile,
          isLoading: false,
        );
      } else {
        // Default to demo profile if not found
        final demoProfile = await DatabaseHelper.instance.getProfile(DemoDataSeeder.demoUserId);
        state = state.copyWith(
          status: AuthStatus.demo,
          userId: DemoDataSeeder.demoUserId,
          profile: demoProfile,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loginDemoMode() async {
    state = state.copyWith(isLoading: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUserId, DemoDataSeeder.demoUserId);
    await prefs.setString(_prefAuthStatus, AuthStatus.demo.name);

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
    final cleanEmail = email.trim().toLowerCase();
    final userId = 'user-${cleanEmail.replaceAll(RegExp(r'[^a-z0-9]'), '_')}';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUserId, userId);
    await prefs.setString(_prefAuthStatus, AuthStatus.authenticated.name);

    var profile = await DatabaseHelper.instance.getProfile(userId);
    if (profile == null) {
      // Create fresh candidate profile for new real user
      profile = CandidateProfile(
        id: 'profile-$userId',
        userId: userId,
        fullName: cleanEmail.contains('@') ? cleanEmail.split('@').first : 'Candidate',
        currentRole: 'Software Developer',
        yearsExperience: 2,
        targetRole: 'Target Role',
        targetIndustry: 'Technology',
        location: 'Remote',
        workPreference: 'Full-time',
        summary: 'Candidate profile for $cleanEmail',
        skills: ['Flutter', 'Dart', 'REST APIs'],
        experience: [],
        projects: [],
        education: [],
        certifications: [],
        technologies: ['Flutter', 'Dart'],
      );
      await DatabaseHelper.instance.saveProfile(profile);
    }

    state = state.copyWith(
      status: AuthStatus.authenticated,
      userId: userId,
      profile: profile,
      isLoading: false,
    );
  }

  Future<void> saveOnboardingProfile(CandidateProfile profile) async {
    state = state.copyWith(isLoading: true);
    final activeUserId = state.userId ?? DemoDataSeeder.demoUserId;
    final updatedProfile = profile.copyWith(userId: activeUserId);

    await DatabaseHelper.instance.saveProfile(updatedProfile);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUserId, activeUserId);
    await prefs.setString(_prefAuthStatus, AuthStatus.authenticated.name);

    state = state.copyWith(
      status: AuthStatus.authenticated,
      profile: updatedProfile,
      isLoading: false,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefUserId);
    await prefs.setString(_prefAuthStatus, AuthStatus.unauthenticated.name);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

