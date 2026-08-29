import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiKeyManager {
  static const _keyOpenAi = 'hirelens_openai_api_key';
  static const _keyGemini = 'hirelens_gemini_api_key';
  static const _storage = FlutterSecureStorage();

  static Future<void> saveOpenAiKey(String apiKey) async {
    await _storage.write(key: _keyOpenAi, value: apiKey.trim());
  }

  static Future<String?> getOpenAiKey() async {
    return await _storage.read(key: _keyOpenAi);
  }

  static Future<void> saveGeminiKey(String apiKey) async {
    await _storage.write(key: _keyGemini, value: apiKey.trim());
  }

  static Future<String?> getGeminiKey() async {
    return await _storage.read(key: _keyGemini);
  }

  static Future<void> clearKeys() async {
    await _storage.delete(key: _keyOpenAi);
    await _storage.delete(key: _keyGemini);
  }
}
