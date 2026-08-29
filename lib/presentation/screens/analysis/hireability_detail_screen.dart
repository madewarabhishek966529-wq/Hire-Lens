import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/analysis_provider.dart';

class HireabilityDetailScreen extends ConsumerWidget {
  final String jobId;

  const HireabilityDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(analysisProvider);
    final score = analysisState.score;

    final overall = score?.overallScore ?? 74;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hireability Score Breakdown'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score Overview Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      '$overall',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlueLight,
                      ),
                    ),
                    const Text(
                      'Estimated Job-Fit Score',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'An estimated job-fit score based on your supplied resume and target job description.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textMutedDark),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Sub-Score Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildScoreBar(context, 'Technical Skills', score?.technicalSkillsScore ?? 82),
            _buildScoreBar(context, 'Keyword Alignment', score?.keywordAlignmentScore ?? 84),
            _buildScoreBar(context, 'Resume Quality', score?.resumeQualityScore ?? 79),
            _buildScoreBar(context, 'Experience Relevance', score?.experienceRelevanceScore ?? 76),
            _buildScoreBar(context, 'Seniority Alignment', score?.seniorityAlignmentScore ?? 68),
            _buildScoreBar(context, 'Project Evidence', score?.projectEvidenceScore ?? 61),

            const SizedBox(height: 24),

            const Text(
              'Why is this score 74?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.matchStrong, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Key Strengths',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildFactorItem('Direct production Flutter app deployment on Google Play and App Store.'),
                    _buildFactorItem('Strong Riverpod state management and Dio REST API caching match.'),
                    _buildFactorItem('Offline-first architecture experience with SQLite database.'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.warning_amber, color: AppColors.priorityHigh, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Key Weaknesses & Gaps',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildFactorItem('No production AWS container deployment or cloud monitoring evidence.'),
                    _buildFactorItem('Lacks Kubernetes experience listed in nice-to-have requirements.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar(BuildContext context, String title, int val) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Text(
                '$val%',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlueLight),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: val / 100.0,
              minHeight: 8,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
