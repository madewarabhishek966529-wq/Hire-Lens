import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/evidence.dart';
import '../../providers/analysis_provider.dart';

class EvidenceGridScreen extends ConsumerWidget {
  final String jobId;

  const EvidenceGridScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(analysisProvider);
    final evidenceItems = analysisState.evidenceItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidence Engine Grid'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Requirement → Candidate Evidence',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'HireLens matches job requirements directly against quotes in your resume with assigned confidence levels.',
              style: TextStyle(color: AppColors.textMutedDark, fontSize: 13),
            ),
            const SizedBox(height: 16),

            if (evidenceItems.isEmpty)
              const Center(child: Text('No evidence items loaded.'))
            else
              Column(
                children: evidenceItems.map((item) => _buildEvidenceCard(context, item)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceCard(BuildContext context, EvidenceItem item) {
    Color confidenceColor = AppColors.matchStrong;
    String confLabel = 'HIGH CONFIDENCE';
    if (item.confidence == EvidenceConfidence.medium) {
      confidenceColor = AppColors.matchPartial;
      confLabel = 'MEDIUM CONFIDENCE';
    } else if (item.confidence == EvidenceConfidence.low) {
      confidenceColor = AppColors.priorityHigh;
      confLabel = 'LOW CONFIDENCE';
    } else if (item.confidence == EvidenceConfidence.none) {
      confidenceColor = AppColors.matchMissing;
      confLabel = 'NO EVIDENCE FOUND';
    }

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
                    item.requirementTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: confidenceColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    confLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: confidenceColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Candidate Resume Evidence Quote:',
              style: TextStyle(fontSize: 11, color: AppColors.textMutedDark),
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
                border: Border.all(color: AppColors.darkBorder.withValues(alpha: 0.5)),
              ),
              child: Text(
                '"${item.candidateQuote}"',
                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.explanation,
              style: const TextStyle(fontSize: 12, color: AppColors.textMutedDark),
            ),
          ],
        ),
      ),
    );
  }
}
