import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/resume_suggestion.dart';
import '../../providers/resume_provider.dart';
import 'truth_guard_modal.dart';

class ResumeOptimizerScreen extends ConsumerWidget {
  final String jobId;

  const ResumeOptimizerScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(resumeOptimizerProvider);
    final suggestions = state.suggestions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Bullet Optimizer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Side-by-Side Bullet Improvement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'HireLens improves bullet impact and keyword alignment while preserving fact truthfulness.',
              style: TextStyle(color: AppColors.textMutedDark, fontSize: 13),
            ),
            const SizedBox(height: 16),

            if (suggestions.isEmpty)
              const Center(child: Text('No bullet suggestions available.'))
            else
              Column(
                children: suggestions
                    .map((sug) => _buildSuggestionCard(context, ref, sug))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(
      BuildContext context, WidgetRef ref, ResumeSuggestion sug) {
    final hasTruthFlag = sug.truthGuardFlags.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Matched: ${sug.matchedRequirement}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlueLight,
                    ),
                  ),
                ),
                const Spacer(),
                if (hasTruthFlag)
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => TruthGuardModal(
                          flag: sug.truthGuardFlags.first,
                          onAction: (action) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Action selected: $action')),
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.priorityHigh.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.priorityHigh),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber,
                              size: 12, color: AppColors.priorityHigh),
                          SizedBox(width: 4),
                          Text(
                            'Truth Guard Flag',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.priorityHigh,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Original vs Improved Comparison
            const Text(
              'ORIGINAL BULLET',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textMutedDark,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurface
                    : AppColors.lightCard,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                sug.originalBullet,
                style: const TextStyle(fontSize: 13, color: AppColors.textMutedDark),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'SUGGESTED BULLET (IMPROVED)',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.matchStrong,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.matchStrong.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.matchStrong.withValues(alpha: 0.4)),
              ),
              child: Text(
                sug.suggestedBullet,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'Why it changed: ${sug.whyItChanged}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMutedDark),
            ),

            const SizedBox(height: 14),

            // Accept / Reject / Edit Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref
                          .read(resumeOptimizerProvider.notifier)
                          .updateSuggestionStatus(
                              sug.id, SuggestionStatus.rejected);
                    },
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(resumeOptimizerProvider.notifier)
                          .updateSuggestionStatus(
                              sug.id, SuggestionStatus.accepted);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Accepted resume suggestion!'),
                          backgroundColor: AppColors.matchStrong,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
