import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/config/api_config.dart';

class ApiKeysScreen extends StatefulWidget {
  @override
  _ApiKeysScreenState createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends State<ApiKeysScreen> {
  final TextEditingController _alphaVantageController = TextEditingController();
  final TextEditingController _dhanClientIdController = TextEditingController();
  final TextEditingController _dhanAccessTokenController = TextEditingController();

  bool _obscureAlphaVantage = true;
  bool _obscureDhanClientId = true;
  bool _obscureDhanAccessToken = true;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadExistingKeys();
  }

  void _loadExistingKeys() async {
    final alphaKey = await ApiConfig.getAlphaVantageKey();
    final dhanClientId = await ApiConfig.getDhanClientId();
    final dhanAccessToken = await ApiConfig.getDhanAccessToken();

    setState(() {
      _alphaVantageController.text = alphaKey ?? '';
      _dhanClientIdController.text = dhanClientId ?? '';
      _dhanAccessTokenController.text = dhanAccessToken ?? '';
    });
  }

  void _submitKeys() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    bool hasAlphaVantage = _alphaVantageController.text.trim().isNotEmpty;
    bool hasDhanClientId = _dhanClientIdController.text.trim().isNotEmpty;
    bool hasDhanAccessToken = _dhanAccessTokenController.text.trim().isNotEmpty;

    // Validate Dhan credentials (both or none)
    if ((hasDhanClientId && !hasDhanAccessToken) || (!hasDhanClientId && hasDhanAccessToken)) {
      setState(() => _isSubmitting = false);
      Get.snackbar(
        'Error',
        'Please provide both Dhan Client ID and Access Token, or leave both empty',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    // Check if at least one set of credentials is provided
    bool hasAnyCredentials = hasAlphaVantage || (hasDhanClientId && hasDhanAccessToken);
    if (!hasAnyCredentials) {
      setState(() => _isSubmitting = false);
      Get.snackbar(
        'Error',
        'Please provide at least one set of API credentials',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      // Save Alpha Vantage key
      if (hasAlphaVantage) {
        await ApiConfig.saveAlphaVantageKey(_alphaVantageController.text.trim());
      }

      // Save Dhan credentials
      if (hasDhanClientId && hasDhanAccessToken) {
        await ApiConfig.saveDhanCredentials(
          _dhanClientIdController.text.trim(),
          _dhanAccessTokenController.text.trim(),
        );
      }

      setState(() => _isSubmitting = false);

      // Show success message
      _showSuccessDialog(hasAlphaVantage, hasDhanClientId && hasDhanAccessToken);
    } catch (e) {
      setState(() => _isSubmitting = false);
      Get.snackbar(
        'Error',
        'Failed to save API keys: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  void _showSuccessDialog(bool hasAlphaVantage, bool hasDhan) {
    String message = '';

    if (hasAlphaVantage && hasDhan) {
      message = 'Thank you for providing your Alphavantage and Dhan API Keys. You can now add stocks manually and fetch your holdings from Dhan.';
    } else if (hasAlphaVantage) {
      message = 'Thank you for providing your Alphavantage API Key, you can now add stock manually.';
    } else if (hasDhan) {
      message = 'Thank you for providing your Dhan API Keys. You can now fetch your holdings from Dhan.';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('API Keys Saved'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Get.back(); // Go back to previous screen
            },
            child: Text(
              'OK',
              style: TextStyle(color: AppColors.iosBlue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _alphaVantageController.dispose();
    _dhanClientIdController.dispose();
    _dhanAccessTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iosBackground,
      appBar: AppBar(
        title: Text('API Keys'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.iosText,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.iosBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.iosBlue,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Why do we need API keys?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.iosBlue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '• For manual stock addition please provide your Alphavantage API key\n\n'
                        '• If you have Dhan account and want to fetch your holdings from Dhan then please provide Dhan access token and client ID\n\n'
                        '• You can provide both or either any one of them based on your needs',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.iosBlue,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Alpha Vantage API Key
            Text(
              'Alpha Vantage API Key',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.iosText,
              ),
            ),
            SizedBox(height: 8),
            _buildPasswordField(
              controller: _alphaVantageController,
              hint: 'Enter your Alpha Vantage API key',
              obscureText: _obscureAlphaVantage,
              onToggleVisibility: () {
                setState(() {
                  _obscureAlphaVantage = !_obscureAlphaVantage;
                });
              },
            ),

            SizedBox(height: 20),

            // Dhan Credentials Section
            Text(
              'Dhan API Credentials',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.iosText,
              ),
            ),
            SizedBox(height: 8),

            // Dhan Client ID
            Text(
              'Client ID',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.iosSecondaryText,
              ),
            ),
            SizedBox(height: 4),
            _buildPasswordField(
              controller: _dhanClientIdController,
              hint: 'Enter your Dhan Client ID',
              obscureText: _obscureDhanClientId,
              onToggleVisibility: () {
                setState(() {
                  _obscureDhanClientId = !_obscureDhanClientId;
                });
              },
            ),

            SizedBox(height: 12),

            // Dhan Access Token
            Text(
              'Access Token',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.iosSecondaryText,
              ),
            ),
            SizedBox(height: 4),
            _buildPasswordField(
              controller: _dhanAccessTokenController,
              hint: 'Enter your Dhan Access Token',
              obscureText: _obscureDhanAccessToken,
              onToggleVisibility: () {
                setState(() {
                  _obscureDhanAccessToken = !_obscureDhanAccessToken;
                });
              },
            ),

            SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitKeys,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.iosBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Saving...'),
                  ],
                )
                    : Text(
                  'Save API Keys',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppColors.iosGray,
          ),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.iosSeparator),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.iosSeparator),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.iosBlue, width: 2),
        ),
      ),
    );
  }

  // Debug code, need to remove
  void _debugShowSavedKeys() async {
    final clientId = await ApiConfig.getDhanClientId();
    final accessToken = await ApiConfig.getDhanAccessToken();

    print('Saved Client ID: $clientId');
    print('Saved Access Token: ${accessToken?.substring(0, 10)}...');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Debug: Saved Keys'),
        content: Text(
            'Client ID: ${clientId ?? 'Not set'}\n'
                'Access Token: ${accessToken != null ? '${accessToken.substring(0, 10)}...' : 'Not set'}'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
// Add this method to your API Keys screen
  void _debugToken() async {
    final token = await ApiConfig.getDhanAccessToken();
    if (token == null) {
      print('No token found');
      return;
    }

    // Basic JWT parsing (just for debugging - don't use in production)
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = parts[1];
        // Add padding if needed
        String normalizedPayload = payload;
        switch (payload.length % 4) {
          case 2:
            normalizedPayload += '==';
            break;
          case 3:
            normalizedPayload += '=';
            break;
        }

        final decoded = utf8.decode(base64Decode(normalizedPayload));
        print('Token payload: $decoded');
      }
    } catch (e) {
      print('Could not decode token: $e');
    }
  }

}
