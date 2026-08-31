import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/skill_gap.dart';
import '../../providers/analysis_provider.dart';

class SkillGapsScreen extends ConsumerWidget {
  final String jobId;

  const SkillGapsScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(analysisProvider);
    final gaps = analysisState.skillGaps;

    final strongMatches = gaps.where((g) => g.status == GapMatchStatus.strong).toList();
    final partialMatches = gaps.where((g) => g.status == GapMatchStatus.partial).toList();
    final missingGaps = gaps.where((g) => g.status == GapMatchStatus.missing).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Skill Gap Priorities'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Critical Gaps'),
              Tab(text: 'Partial Match'),
              Tab(text: 'Strong Match'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGapList(context, missingGaps.isNotEmpty ? missingGaps : gaps),
            _buildGapList(context, partialMatches),
            _buildGapList(context, strongMatches),
          ],
        ),
      ),
    );
  }

  Widget _buildGapList(BuildContext context, List<SkillGap> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text('No skill gaps found in this category.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final gap = list[index];
        Color prioColor = AppColors.priorityHigh;
        if (gap.priority == GapPriority.critical) prioColor = AppColors.priorityCritical;
        if (gap.priority == GapPriority.medium) prioColor = AppColors.priorityMedium;
        if (gap.priority == GapPriority.low) prioColor = AppColors.priorityLow;

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        gap.skillName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: prioColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${gap.priority.name.toUpperCase()} PRIORITY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: prioColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Current Evidence: ${gap.currentEvidence}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Missing Proof: ${gap.missingDetails}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMutedDark),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 16, color: AppColors.primaryBlueLight),
                          SizedBox(width: 6),
                          Text(
                            'Recommended Action to Build Evidence:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlueLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gap.recommendedAction,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
