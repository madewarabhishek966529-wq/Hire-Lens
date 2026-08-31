import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/ai_provider.dart';
import '../../data/remote/api_key_manager.dart';
import '../../data/remote/fallback_ai_engine.dart';
import '../../data/remote/openai_provider.dart';

/// FutureProvider that fetches saved key and constructs active AiProvider
final activeAiKeyProvider = FutureProvider<String?>((ref) async {
  final keyFromStorage = await ApiKeyManager.getOpenAiKey();
  if (keyFromStorage != null && keyFromStorage.isNotEmpty) {
    return keyFromStorage;
  }
  const envKey = String.fromEnvironment('OPENAI_API_KEY');
  if (envKey.isNotEmpty) {
    return envKey;
  }
  return null;
});

/// Provider for dynamic AiProvider instance
final aiServiceProvider = Provider<AiProvider>((ref) {
  final keyAsync = ref.watch(activeAiKeyProvider);
  final apiKey = keyAsync.asData?.value;

  if (apiKey != null && apiKey.isNotEmpty) {
    return OpenAiProvider(
      dio: Dio(),
      apiKey: apiKey,
    );
  }
  return FallbackAiEngine();
});
