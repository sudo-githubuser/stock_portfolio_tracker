import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiConfig {
  static const String dhanBaseUrl = 'https://api.dhan.co';
  static const String alphaVantageBaseUrl = 'https://www.alphavantage.co/query';

  // Secure storage instance
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys for secure storage
  static const String _dhanClientIdKey = 'client_id';
  static const String _dhanAccessTokenKey = 'dhan_access_token';
  static const String _alphaVantageKeyKey = 'api_key';

  // Save API credentials securely
  static Future<void> saveDhanCredentials(String clientId, String accessToken) async {
    await _secureStorage.write(key: _dhanClientIdKey, value: clientId);
    await _secureStorage.write(key: _dhanAccessTokenKey, value: accessToken);
  }

  static Future<void> saveAlphaVantageKey(String apiKey) async {
    await _secureStorage.write(key: _alphaVantageKeyKey, value: apiKey);
  }

  // Retrieve API credentials securely
  static Future<String?> getDhanClientId() async {
    return await _secureStorage.read(key: _dhanClientIdKey);
  }

  static Future<String?> getDhanAccessToken() async {
    return await _secureStorage.read(key: _dhanAccessTokenKey);
  }

  static Future<String?> getAlphaVantageKey() async {
    return await _secureStorage.read(key: _alphaVantageKeyKey);
  }

  // Check if credentials exist
  static Future<bool> hasDhanCredentials() async {
    final clientId = await getDhanClientId();
    final accessToken = await getDhanAccessToken();
    return clientId != null && accessToken != null &&
        clientId.isNotEmpty && accessToken.isNotEmpty;
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
    await _secureStorage.delete(key: _dhanClientIdKey);
    await _secureStorage.delete(key: _dhanAccessTokenKey);
  }

  static Future<void> clearAlphaVantageKey() async {
    await _secureStorage.delete(key: _alphaVantageKeyKey);
  }

  static Future<void> clearAllCredentials() async {
    await _secureStorage.deleteAll();
  }

  // Get all stored keys (for debugging - don't use in production)
  static Future<Map<String, String>> getAllStoredKeys() async {
    return await _secureStorage.readAll();
  }
}
