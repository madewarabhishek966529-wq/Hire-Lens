import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/job.dart';
import '../../providers/job_provider.dart';
import '../../providers/analysis_provider.dart';

class JobWorkspaceScreen extends ConsumerWidget {
  final String jobId;

  const JobWorkspaceScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobState = ref.watch(jobProvider);
    final analysisState = ref.watch(analysisProvider);

    final job = jobState.jobs.firstWhere(
      (j) => j.id == jobId,
      orElse: () => jobState.selectedJob ?? _fallbackJob(jobId),
    );

    final score = analysisState.score?.overallScore ?? 74;

    return Scaffold(
      appBar: AppBar(
        title: Text(job.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Overview Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.business,
                            color: AppColors.primaryBlueLight,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${job.company} • ${job.location}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCol('Hireability Score', '$score/100', AppColors.primaryBlueLight),
                        _buildStatCol('Skill Match', '84%', AppColors.matchStrong),
                        _buildStatCol('Resume Alignment', '79%', AppColors.accentVioletLight),
                        _buildStatCol('Interview Readiness', '84%', AppColors.matchPartial),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Job Intelligence Workspaces',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 4 Key Workspace Navigation Action Tiles
            _buildWorkspaceTile(
              context,
              title: '1. Skill Gap Analysis & Priorities',
              subtitle: 'Identify Strong Match, Partial Match, and Missing Evidence.',
              icon: Icons.pie_chart_outline,
              color: AppColors.primaryBlue,
              onTap: () => context.push('/jobs/$jobId/gaps'),
            ),
            const SizedBox(height: 12),
            _buildWorkspaceTile(
              context,
              title: '2. Evidence Engine Grid',
              subtitle: 'Map candidate resume quotes directly to job requirements.',
              icon: Icons.verified_outlined,
              color: AppColors.matchStrong,
              onTap: () => context.push('/jobs/$jobId/evidence'),
            ),
            const SizedBox(height: 12),
            _buildWorkspaceTile(
              context,
              title: '3. Resume Optimizer & Truth Guard',
              subtitle: 'Improve bullet phrasing & flag unsupported AI metrics.',
              icon: Icons.description_outlined,
              color: AppColors.accentViolet,
              onTap: () => context.push('/jobs/$jobId/resume'),
            ),
            const SizedBox(height: 12),
            _buildWorkspaceTile(
              context,
              title: '4. AI Mock Interview Practice',
              subtitle: 'Simulate role-specific technical & behavioral rounds with STAR scoring.',
              icon: Icons.record_voice_over_outlined,
              color: AppColors.matchPartial,
              onTap: () => context.push('/interview'),
            ),

            const SizedBox(height: 24),

            // Classified Requirements Accordion
            const Text(
              'Extracted Job Requirements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildRequirementsList(context, job),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textMutedDark),
        ),
      ],
    );
  }

  Widget _buildWorkspaceTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMutedDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementsList(BuildContext context, Job job) {
    if (job.requirements.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No requirements extracted.'),
        ),
      );
    }

    return Column(
      children: job.requirements.map((req) {
        Color badgeColor = AppColors.matchStrong;
        if (req.category == 'preferred') badgeColor = AppColors.matchPartial;
        if (req.category == 'nice_to_have') badgeColor = AppColors.matchInfo;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              req.category == 'must_have' ? Icons.check_circle : Icons.circle_outlined,
              color: badgeColor,
            ),
            title: Text(
              req.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(req.rationale),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                req.category.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Job _fallbackJob(String id) => Job(
        id: id,
        userId: 'user-current',
        title: 'Mobile Application Developer',
        company: 'TechCorp',
        location: 'San Francisco, CA',
        employmentType: 'Full-time',
        description: '',
        applicationUrl: '',
        seniority: 'Mid-Level',
        minYearsExp: 2,
        requirements: [],
        createdAt: DateTime.now(),
      );
}
