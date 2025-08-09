import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiConfig {
  static const String dhanBaseUrl = 'https://api.dhan.co/v2';
  static const String alphaVantageBaseUrl = 'https://www.alphavantage.co/query';

  // Secure storage instance
  static const _secureStorage = FlutterSecureStorage();

  // Keys for secure storage
  static const String _dhanAccessTokenKey = 'dhan_access_token';
  static const String _alphaVantageKeyKey = 'alpha_vantage_api_key';

  // For Dhan, we only need access token (client ID is embedded in the JWT token)
  static Future<void> saveDhanCredentials(String clientId, String accessToken) async {
    // We only save the access token as that's all we need for API calls
    await _secureStorage.write(key: _dhanAccessTokenKey, value: accessToken);
  }

  static Future<void> saveAlphaVantageKey(String apiKey) async {
    await _secureStorage.write(key: _alphaVantageKeyKey, value: apiKey);
  }

  // For backward compatibility, we'll still have getDhanClientId but it won't be used
  static Future<String?> getDhanClientId() async {
    // Client ID is not needed for API calls, it's embedded in the JWT token
    return null;
  }

  static Future<String?> getDhanAccessToken() async {
    return await _secureStorage.read(key: _dhanAccessTokenKey);
  }

  static Future<String?> getAlphaVantageKey() async {
    return await _secureStorage.read(key: _alphaVantageKeyKey);
  }

  // Check if credentials exist
  static Future<bool> hasDhanCredentials() async {
    final accessToken = await getDhanAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  static Future<bool> hasAlphaVantageKey() async {
    final apiKey = await getAlphaVantageKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  // Check if all credentials are configured
  static Future<bool> isFullyConfigured() async {
    final hasDhan = await hasDhanCredentials();
    final hasAlpha = await hasAlphaVantageKey();
    return hasDhan && hasAlpha;
  }

  // Clear stored credentials
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
