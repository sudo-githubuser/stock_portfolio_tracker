import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';

class DhanLoginScreen extends StatefulWidget {
  @override
  _DhanLoginScreenState createState() => _DhanLoginScreenState();
}

class _DhanLoginScreenState extends State<DhanLoginScreen> {
  final TextEditingController _clientIdController = TextEditingController();
  final TextEditingController _accessTokenController = TextEditingController();
  bool _obscureClientId = true;
  bool _obscureAccessToken = true;

  @override
  void dispose() {
    _clientIdController.dispose();
    _accessTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iosBackground,
      appBar: AppBar(
        title: Text('Dhan Login'),
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
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance,
                    size: 50,
                    color: AppColors.iosBlue,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Connect to Dhan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.iosText,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enter your Dhan credentials to fetch your holdings',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.iosSecondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Client ID Field
            _buildPasswordField(
              controller: _clientIdController,
              label: 'Client ID',
              hint: 'Enter your Dhan Client ID',
              obscureText: _obscureClientId,
              onToggleVisibility: () {
                setState(() {
                  _obscureClientId = !_obscureClientId;
                });
              },
            ),

            SizedBox(height: 20),

            // Access Token Field
            _buildPasswordField(
              controller: _accessTokenController,
              label: 'Access Token',
              hint: 'Enter your Dhan Access Token',
              obscureText: _obscureAccessToken,
              onToggleVisibility: () {
                setState(() {
                  _obscureAccessToken = !_obscureAccessToken;
                });
              },
            ),

            SizedBox(height: 16),

            // Security Info
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.iosBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.iosBlue,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your credentials are securely stored locally and never shared with third parties.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.iosBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.iosGray.withOpacity(0.2),
                        foregroundColor: AppColors.iosText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitCredentials,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Connect',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Help Text
            Center(
              child: TextButton(
                onPressed: () {
                  // Show help dialog or navigate to help screen
                  _showHelpDialog();
                },
                child: Text(
                  'Need help finding your credentials?',
                  style: TextStyle(
                    color: AppColors.iosBlue,
                    fontSize: 14,
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
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.iosText,
          ),
        ),
        SizedBox(height: 8),
        TextField(
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
        ),
      ],
    );
  }

  void _submitCredentials() {
    if (_clientIdController.text.isEmpty || _accessTokenController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in both Client ID and Access Token',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    // Show loading indicator
    Get.dialog(
      Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.iosBlue),
              SizedBox(height: 16),
              Text('Connecting to Dhan...'),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Simulate API call
    Future.delayed(Duration(seconds: 2), () {
      Get.back(); // Close loading dialog

      // Success feedback
      Get.snackbar(
        'Success',
        'Successfully connected to Dhan! Holdings will be fetched.',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );

      // Go back to previous screen
      Get.back();
    });
  }

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Finding Your Credentials'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To find your Dhan credentials:'),
            SizedBox(height: 8),
            Text('1. Login to your Dhan account'),
            Text('2. Go to API section in settings'),
            Text('3. Copy Client ID and Access Token'),
            SizedBox(height: 12),
            Text(
              'Note: These credentials are required to fetch your holdings securely.',
              style: TextStyle(fontSize: 12, color: AppColors.iosSecondaryText),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Got it', style: TextStyle(color: AppColors.iosBlue)),
          ),
        ],
      ),
    );
  }
}
