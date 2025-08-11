import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ApiConfig {
  static const String dhanBaseUrl = 'https://api.dhan.co/v2';
  static const String alphaVantageBaseUrl = 'https://www.alphavantage.co/query';

  static const _secureStorage = FlutterSecureStorage();

  static const String _dhanAccessTokenKey = 'dhan_access_token';
  static const String _alphaVantageKeysKey = 'alpha_vantage_api_keys';
  static const String _currentAlphaKeyIndexKey = 'current_alpha_key_index';

  static Future<void> saveDhanCredentials(String clientId, String accessToken) async {
    await _secureStorage.write(key: _dhanAccessTokenKey, value: accessToken);
  }

  static Future<void> saveAlphaVantageKeys(List<String> apiKeys) async {
    final keysJson = jsonEncode(apiKeys);
    await _secureStorage.write(key: _alphaVantageKeysKey, value: keysJson);
    await _secureStorage.write(key: _currentAlphaKeyIndexKey, value: '0');
  }

  static Future<void> addAlphaVantageKey(String apiKey) async {
    final existingKeys = await getAlphaVantageKeys();
    if (!existingKeys.contains(apiKey) && existingKeys.length < 10) {
      existingKeys.add(apiKey);
      await saveAlphaVantageKeys(existingKeys);
    }
  }

  static Future<void> removeAlphaVantageKey(String apiKey) async {
    final existingKeys = await getAlphaVantageKeys();
    existingKeys.remove(apiKey);
    await saveAlphaVantageKeys(existingKeys);
  }

  static Future<List<String>> getAlphaVantageKeys() async {
    final keysJson = await _secureStorage.read(key: _alphaVantageKeysKey);
    if (keysJson == null || keysJson.isEmpty) return [];

    try {
      final List<dynamic> keysList = jsonDecode(keysJson);
      return keysList.cast<String>();
    } catch (e) {
      return [];
    }
  }

  static Future<String?> getCurrentAlphaVantageKey() async {
    final keys = await getAlphaVantageKeys();
    if (keys.isEmpty) return null;

    final currentIndexStr = await _secureStorage.read(key: _currentAlphaKeyIndexKey);
    final currentIndex = int.tryParse(currentIndexStr ?? '0') ?? 0;

    if (currentIndex < keys.length) {
      return keys[currentIndex];
    }
    return keys.first;
  }

  static Future<void> switchToNextAlphaVantageKey() async {
    final keys = await getAlphaVantageKeys();
    if (keys.length <= 1) return;

    final currentIndexStr = await _secureStorage.read(key: _currentAlphaKeyIndexKey);
    final currentIndex = int.tryParse(currentIndexStr ?? '0') ?? 0;
    final nextIndex = (currentIndex + 1) % keys.length;

    await _secureStorage.write(key: _currentAlphaKeyIndexKey, value: nextIndex.toString());
    print('Switched to Alpha Vantage key index: $nextIndex');
  }

  static Future<String?> getDhanClientId() async {
    return null;
  }

  static Future<String?> getDhanAccessToken() async {
    return await _secureStorage.read(key: _dhanAccessTokenKey);
  }

  static Future<String?> getAlphaVantageApiKey() async {
    return await getCurrentAlphaVantageKey();
  }

  static Future<bool> hasDhanCredentials() async {
    final accessToken = await getDhanAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  static Future<bool> hasAlphaVantageKey() async {
    final keys = await getAlphaVantageKeys();
    return keys.isNotEmpty;
  }

  static Future<bool> isFullyConfigured() async {
    final hasDhan = await hasDhanCredentials();
    final hasAlpha = await hasAlphaVantageKey();
    return hasDhan && hasAlpha;
  }

  static Future<void> clearDhanCredentials() async {
    await _secureStorage.delete(key: _dhanAccessTokenKey);
  }

  static Future<void> clearAlphaVantageKeys() async {
    await _secureStorage.delete(key: _alphaVantageKeysKey);
    await _secureStorage.delete(key: _currentAlphaKeyIndexKey);
  }

  static Future<void> clearAllCredentials() async {
    await _secureStorage.deleteAll();
  }
}
