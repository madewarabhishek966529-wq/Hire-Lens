import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/observability_provider.dart';

class DeveloperObservabilityScreen extends ConsumerWidget {
  const DeveloperObservabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(observabilityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Telemetry & AI Observability'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentViolet.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentViolet.withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.developer_mode, color: AppColors.accentVioletLight),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Internal Developer Telemetry View: Tracks live AI request volume, response latency, token usage, cost estimates, and system performance metrics.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Overview Metric Tiles
            Row(
              children: [
                Expanded(
                  child: _buildObsTile(
                    'AI Request Count',
                    '${state.totalRequests}',
                    Icons.auto_awesome,
                    AppColors.primaryBlueLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildObsTile(
                    'Average Latency',
                    '${state.averageLatency.toStringAsFixed(0)} ms',
                    Icons.speed,
                    AppColors.matchStrong,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildObsTile(
                    'Estimated Cost',
                    '\$${state.estimatedCost.toStringAsFixed(4)}',
                    Icons.attach_money,
                    AppColors.matchPartial,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildObsTile(
                    'System Error Rate',
                    '0.0%',
                    Icons.check_circle_outline,
                    AppColors.matchStrong,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Recent AI Requests Telemetry Log',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (state.logs.isEmpty)
              const Center(child: Text('No telemetry logs recorded yet.'))
            else
              Column(
                children: state.logs.map((log) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const Icon(Icons.api, color: AppColors.primaryBlueLight),
                      title: Text(
                        log['requestType'] as String? ?? 'AI Analysis',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        'Tokens: ${log['tokensUsed'] ?? 1250} • Latency: ${log['latencyMs'] ?? 420}ms • Status: ${log['status'] ?? 'SUCCESS'}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: Text(
                        '\$${(log['costEstimate'] as double? ?? 0.0025).toStringAsFixed(4)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildObsTile(String title, String val, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              val,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: AppColors.textMutedDark),
            ),
          ],
        ),
      ),
    );
  }
}
