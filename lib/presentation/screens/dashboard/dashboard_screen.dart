import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/analysis_provider.dart';
import '../../providers/interview_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final jobState = ref.watch(jobProvider);
    final analysisState = ref.watch(analysisProvider);
    final interviewState = ref.watch(interviewProvider);

    final candidateName = authState.profile?.fullName ?? 'Alex';
    final score = analysisState.score?.overallScore ?? 74;
    final scoreChange = analysisState.score?.scoreChange ?? 6;
    final selectedJob = jobState.selectedJob;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.matchStrong,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'HireLens Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Developer Observability',
            onPressed: () => context.push('/admin/observability'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Header
            Text(
              'Good morning, $candidateName',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Here is your career strategy roadmap for ${selectedJob?.title ?? "your target role"}.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // 1. Hireability Score Hero Ring Card
            _buildHireabilityHeroCard(context, score, scoreChange, selectedJob),

            const SizedBox(height: 20),

            // 2. Next Best Action Card
            _buildNextBestActionCard(context),

            const SizedBox(height: 20),

            // 3. Quick Stats Grid
            _buildStatsGrid(context, analysisState),

            const SizedBox(height: 20),

            // 4. Target Job Workspace Quick Card
            if (selectedJob != null) ...[
              _buildTargetJobCard(context, selectedJob),
              const SizedBox(height: 20),
            ],

            // 5. Recent Interview Score Preview Card
            _buildRecentInterviewCard(context, interviewState),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHireabilityHeroCard(
      BuildContext context, int score, int scoreChange, selectedJob) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Circular Score Dial
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: score / 100.0,
                      strokeWidth: 9,
                      backgroundColor: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$score',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlueLight,
                        ),
                      ),
                      const Text(
                        '/ 100',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMutedDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Hireability Score',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.matchStrong.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+$scoreChange this week',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.matchStrong,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      selectedJob != null
                          ? 'Estimated job-fit match for ${selectedJob.title} at ${selectedJob.company}.'
                          : 'Target role match overview.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        if (selectedJob != null) {
                          context.push('/jobs/${selectedJob.id}/analysis');
                        }
                      },
                      child: const Row(
                        children: [
                          Text(
                            'Why is my score 74?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlueLight,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: AppColors.primaryBlueLight,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: AppColors.textMutedDark),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'An estimated job-fit score based on your supplied resume and target job description.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMutedDark),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildNextBestActionCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.priorityHigh.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: AppColors.priorityHigh,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Next Best Action',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.priorityHigh.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'HIGH PRIORITY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.priorityHigh,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Your biggest gap is: AWS Deployment Experience',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.matchPartial,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You mention AWS Lambda, but your resume does not show evidence of deploying or monitoring production infrastructure.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/jobs/demo-job-techcorp/gaps'),
                icon: const Icon(Icons.build_circle_outlined, size: 18),
                label: const Text('View Action Plan & Build Evidence'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, analysisState) {
    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            context,
            title: 'Top Strength',
            value: 'Flutter & Dart',
            subtitle: 'High confidence match',
            icon: Icons.check_circle_outline,
            iconColor: AppColors.matchStrong,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatTile(
            context,
            title: 'Biggest Gap',
            value: 'AWS Deployment',
            subtitle: 'Missing evidence',
            icon: Icons.warning_amber_outlined,
            iconColor: AppColors.priorityHigh,
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMutedDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMutedDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetJobCard(BuildContext context, selectedJob) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.work_outline, color: AppColors.primaryBlueLight),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedJob.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${selectedJob.company} • ${selectedJob.location}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => context.push('/jobs/${selectedJob.id}'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                  child: const Text('Open Workspace'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricItem('Skill Match', '84%'),
                _buildMetricItem('Resume Alignment', '79%'),
                _buildMetricItem('Interview Readiness', '84%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String val) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlueLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMutedDark,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentInterviewCard(BuildContext context, interviewState) {
    final activeSession = interviewState.activeSession;
    final avgScore = activeSession?.averageScore ?? 84;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentViolet.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.record_voice_over,
                color: AppColors.accentVioletLight,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Mock Interview',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Latest Score: $avgScore / 100 (STAR Evaluation)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => context.push('/interview'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentViolet,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              child: const Text('Practice'),
            ),
          ],
        ),
      ),
    );
  }
}
