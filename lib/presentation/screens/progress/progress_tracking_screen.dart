import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';

class ProgressTrackingScreen extends ConsumerWidget {
  const ProgressTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hireability Score Growth',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Track your target job alignment progression over time as you resolve skill gaps.',
              style: TextStyle(color: AppColors.textMutedDark, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Animated fl_chart Line Chart Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: true, drawVerticalLine: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                getTitlesWidget: (val, meta) => Text(
                                  '${val.toInt()}',
                                  style: const TextStyle(fontSize: 10, color: AppColors.textMutedDark),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  switch (val.toInt()) {
                                    case 1:
                                      return const Text('W1', style: TextStyle(fontSize: 11));
                                    case 2:
                                      return const Text('W2', style: TextStyle(fontSize: 11));
                                    case 3:
                                      return const Text('W3', style: TextStyle(fontSize: 11));
                                    case 4:
                                      return const Text('W4', style: TextStyle(fontSize: 11));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 1,
                          maxX: 4,
                          minY: 50,
                          maxY: 100,
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(1, 61),
                                FlSpot(2, 67),
                                FlSpot(3, 74),
                                FlSpot(4, 78),
                              ],
                              isCurved: true,
                              color: AppColors.primaryBlueLight,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.primaryBlue.withOpacity(0.15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.trending_up, color: AppColors.matchStrong, size: 18),
                        SizedBox(width: 6),
                        Text(
                          '+17 Points Improvement over 4 Weeks',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.matchStrong),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Activity & Milestones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    context,
                    title: 'Skill Gaps Resolved',
                    value: '3 / 4',
                    icon: Icons.check_circle_outline,
                    color: AppColors.matchStrong,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    context,
                    title: 'Bullets Improved',
                    value: '5 Accepted',
                    icon: Icons.description_outlined,
                    color: AppColors.accentVioletLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    context,
                    title: 'Interviews Done',
                    value: '2 Rounds',
                    icon: Icons.record_voice_over_outlined,
                    color: AppColors.matchPartial,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    context,
                    title: 'Target Jobs',
                    value: '1 Active Workspace',
                    icon: Icons.work_outline,
                    color: AppColors.primaryBlueLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
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
