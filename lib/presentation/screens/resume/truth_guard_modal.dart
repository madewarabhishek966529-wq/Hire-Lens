import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/resume_suggestion.dart';

class TruthGuardModal extends StatelessWidget {
  final TruthGuardFlag flag;
  final Function(String action) onAction;

  const TruthGuardModal({
    super.key,
    required this.flag,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.priorityHigh),
          SizedBox(width: 8),
          Text('Truth Guard Flag'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            flag.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.priorityHigh.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              flag.description,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Reason:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(
            flag.reason,
            style: const TextStyle(color: AppColors.textMutedDark, fontSize: 13),
          ),
          const SizedBox(height: 14),
          const Text(
            'HireLens Resume Truth Guard prevents AI hallucinations or unsupported metric claims.',
            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onAction('Remove');
          },
          child: const Text('Remove Metric', style: TextStyle(color: AppColors.matchMissing)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onAction('Edit');
          },
          child: const Text('Edit Bullet'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onAction('Keep');
          },
          child: const Text('Keep Claim'),
        ),
      ],
    );
  }
}
