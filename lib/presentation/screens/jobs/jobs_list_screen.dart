import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/job_provider.dart';

class JobsListScreen extends ConsumerWidget {
  const JobsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobState = ref.watch(jobProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Target Jobs Workspace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add_check),
            tooltip: 'Application Tracker',
            onPressed: () => context.push('/applications'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/jobs/create'),
        icon: const Icon(Icons.add),
        label: const Text('Add Target Job'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: jobState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : jobState.jobs.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: jobState.jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobState.jobs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: InkWell(
                        onTap: () {
                          ref.read(jobProvider.notifier).selectJob(job.id);
                          context.push('/jobs/${job.id}');
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue
                                          .withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.business,
                                      color: AppColors.primaryBlueLight,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          job.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${job.company} • ${job.location}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '74% Fit',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlueLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${job.requirements.length} Job Requirements Extracted (Must Have, Preferred, Nice to Have)',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.touch_app_outlined,
                                      size: 14, color: AppColors.textMutedDark),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Tap to open job workspace',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppColors.textMutedDark
                                          : AppColors.textMutedLight,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.arrow_forward_ios,
                                      size: 14, color: AppColors.textMutedDark),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work_off_outlined,
                size: 64, color: AppColors.textMutedDark),
            const SizedBox(height: 16),
            const Text(
              'No Target Jobs Saved Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a target job description to run HireLens gap analysis and resume optimization.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMutedDark),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/jobs/create'),
              icon: const Icon(Icons.add),
              label: const Text('Add Target Job'),
            ),
          ],
        ),
      ),
    );
  }
}
