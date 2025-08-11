import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiConfig {
  static const String dhanBaseUrl = 'https://api.dhan.co/v2';
  static const String alphaVantageBaseUrl = 'https://www.alphavantage.co/query';

  static const _secureStorage = FlutterSecureStorage();

  static const String _dhanAccessTokenKey = 'dhan_access_token';
  static const String _alphaVantageKeyKey = 'alpha_vantage_api_key';

  static Future<void> saveDhanCredentials(String clientId, String accessToken) async {
    await _secureStorage.write(key: _dhanAccessTokenKey, value: accessToken);
  }

  static Future<void> saveAlphaVantageKey(String apiKey) async {
    await _secureStorage.write(key: _alphaVantageKeyKey, value: apiKey);
  }

  static Future<void> setAlphaVantageApiKey(String apiKey) async {
    await _secureStorage.write(key: _alphaVantageKeyKey, value: apiKey);
  }

  static Future<String?> getDhanClientId() async {
    return null;
  }

  static Future<String?> getDhanAccessToken() async {
    return await _secureStorage.read(key: _dhanAccessTokenKey);
  }

  static Future<String?> getAlphaVantageKey() async {
    return await _secureStorage.read(key: _alphaVantageKeyKey);
  }

  static Future<String?> getAlphaVantageApiKey() async {
    return await _secureStorage.read(key: _alphaVantageKeyKey);
  }

  static Future<bool> hasDhanCredentials() async {
    final accessToken = await getDhanAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  static Future<bool> hasAlphaVantageKey() async {
    final apiKey = await getAlphaVantageKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  static Future<bool> isFullyConfigured() async {
    final hasDhan = await hasDhanCredentials();
    final hasAlpha = await hasAlphaVantageKey();
    return hasDhan && hasAlpha;
  }

  static Future<void> clearDhanCredentials() async {
    await _secureStorage.delete(key: _dhanAccessTokenKey);
  }

  static Future<void> clearAlphaVantageKey() async {
    await _secureStorage.delete(key: _alphaVantageKeyKey);
  }

  static Future<void> clearAllCredentials() async {
    await _secureStorage.deleteAll();
  }
}
