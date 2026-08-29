import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/application.dart';
import '../../providers/application_provider.dart';

class ApplicationTrackerScreen extends ConsumerWidget {
  const ApplicationTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(applicationProvider);
    final apps = state.applications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Pipeline Tracker'),
      ),
      body: apps.isEmpty
          ? const Center(child: Text('No applications saved in tracker.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    app.jobTitle,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    app.companyName,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<ApplicationStage>(
                              initialValue: app.stage,
                              onSelected: (newStage) {
                                ref
                                    .read(applicationProvider.notifier)
                                    .updateStage(app.id, newStage);
                              },
                              itemBuilder: (context) => ApplicationStage.values
                                  .map(
                                    (stage) => PopupMenuItem(
                                      value: stage,
                                      child: Text(stage.name.toUpperCase()),
                                    ),
                                  )
                                  .toList(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      app.stage.name.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlueLight,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down,
                                        size: 16, color: AppColors.primaryBlueLight),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Notes: ${app.notes}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Applied: ${app.appliedDate.toString().split(' ').first}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMutedDark),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
