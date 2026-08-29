import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/main_scaffold.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/jobs/jobs_list_screen.dart';
import '../screens/jobs/create_job_screen.dart';
import '../screens/jobs/job_workspace_screen.dart';
import '../screens/analysis/hireability_detail_screen.dart';
import '../screens/analysis/evidence_grid_screen.dart';
import '../screens/analysis/skill_gaps_screen.dart';
import '../screens/resume/resume_upload_screen.dart';
import '../screens/resume/resume_optimizer_screen.dart';
import '../screens/interview/mock_interview_screen.dart';
import '../screens/applications/application_tracker_screen.dart';
import '../screens/progress/progress_tracking_screen.dart';
import '../screens/admin/developer_observability_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/onboarding_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/jobs',
          builder: (context, state) => const JobsListScreen(),
        ),
        GoRoute(
          path: '/interview',
          builder: (context, state) => const MockInterviewScreen(),
        ),
        GoRoute(
          path: '/progress',
          builder: (context, state) => const ProgressTrackingScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    // Nested Workspace Detail Routes
    GoRoute(
      path: '/jobs/create',
      builder: (context, state) => const CreateJobScreen(),
    ),
    GoRoute(
      path: '/jobs/:id',
      builder: (context, state) {
        final jobId = state.pathParameters['id'] ?? '';
        return JobWorkspaceScreen(jobId: jobId);
      },
    ),
    GoRoute(
      path: '/jobs/:id/analysis',
      builder: (context, state) {
        final jobId = state.pathParameters['id'] ?? '';
        return HireabilityDetailScreen(jobId: jobId);
      },
    ),
    GoRoute(
      path: '/jobs/:id/evidence',
      builder: (context, state) {
        final jobId = state.pathParameters['id'] ?? '';
        return EvidenceGridScreen(jobId: jobId);
      },
    ),
    GoRoute(
      path: '/jobs/:id/gaps',
      builder: (context, state) {
        final jobId = state.pathParameters['id'] ?? '';
        return SkillGapsScreen(jobId: jobId);
      },
    ),
    GoRoute(
      path: '/jobs/:id/resume',
      builder: (context, state) {
        final jobId = state.pathParameters['id'] ?? '';
        return ResumeOptimizerScreen(jobId: jobId);
      },
    ),
    GoRoute(
      path: '/resume/upload',
      builder: (context, state) => const ResumeUploadScreen(),
    ),
    GoRoute(
      path: '/applications',
      builder: (context, state) => const ApplicationTrackerScreen(),
    ),
    GoRoute(
      path: '/admin/observability',
      builder: (context, state) => const DeveloperObservabilityScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
