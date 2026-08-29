import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database_helper.dart';

class ObservabilityState {
  final List<Map<String, dynamic>> logs;
  final int totalRequests;
  final double averageLatency;
  final double estimatedCost;
  final bool isLoading;

  const ObservabilityState({
    this.logs = const [],
    this.totalRequests = 1,
    this.averageLatency = 420.0,
    this.estimatedCost = 0.0025,
    this.isLoading = false,
  });
}

class ObservabilityNotifier extends StateNotifier<ObservabilityState> {
  ObservabilityNotifier() : super(const ObservabilityState()) {
    loadLogs();
  }

  Future<void> loadLogs() async {
    final logs = await DatabaseHelper.instance.getObservabilityLogs();
    int count = logs.length;
    double totalLatency = 0;
    double totalCost = 0;
    for (final l in logs) {
      totalLatency += (l['latencyMs'] as int? ?? 0);
      totalCost += (l['costEstimate'] as double? ?? 0.0);
    }

    state = ObservabilityState(
      logs: logs,
      totalRequests: count > 0 ? count : 1,
      averageLatency: count > 0 ? totalLatency / count : 420.0,
      estimatedCost: totalCost > 0 ? totalCost : 0.0025,
      isLoading: false,
    );
  }
}

final observabilityProvider =
    StateNotifierProvider<ObservabilityNotifier, ObservabilityState>((ref) {
  return ObservabilityNotifier();
});
