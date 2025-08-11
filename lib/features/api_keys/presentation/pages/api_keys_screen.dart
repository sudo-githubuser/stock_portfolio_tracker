import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/config/api_config.dart';

class ApiKeysScreen extends StatefulWidget {
  @override
  _ApiKeysScreenState createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends State<ApiKeysScreen> {
  final TextEditingController _dhanAccessTokenController = TextEditingController();
  final TextEditingController _alphaVantageKeyController = TextEditingController();

  bool _isDhanTokenVisible = false;
  bool _isAlphaKeyVisible = false;
  bool _isLoading = false;

  bool _hasDhanCredentials = false;
  bool _hasAlphaVantageKey = false;

  @override
  void initState() {
    super.initState();
    _checkExistingCredentials();
  }

  Future<void> _checkExistingCredentials() async {
    final hasDhan = await ApiConfig.hasDhanCredentials();
    final hasAlpha = await ApiConfig.hasAlphaVantageKey();

    setState(() {
      _hasDhanCredentials = hasDhan;
      _hasAlphaVantageKey = hasAlpha;
    });
  }

  Future<void> _saveDhanCredentials() async {
    if (_dhanAccessTokenController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Dhan Access Token',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiConfig.saveDhanCredentials(
        '', // Client ID not needed
        _dhanAccessTokenController.text.trim(),
      );

      setState(() {
        _hasDhanCredentials = true;
        _isLoading = false;
      });

      _dhanAccessTokenController.clear();

      Get.snackbar(
        'Success',
        'Dhan access token saved successfully!',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        'Failed to save Dhan access token: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  Future<void> _saveAlphaVantageKey() async {
    if (_alphaVantageKeyController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Alpha Vantage API key',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiConfig.saveAlphaVantageKey(_alphaVantageKeyController.text.trim());

      setState(() {
        _hasAlphaVantageKey = true;
        _isLoading = false;
      });

      _alphaVantageKeyController.clear();

      Get.snackbar(
        'Success',
        'Alpha Vantage API key saved successfully!',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        'Failed to save Alpha Vantage key: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  Future<void> _clearDhanCredentials() async {
    try {
      await ApiConfig.clearDhanCredentials();
      setState(() => _hasDhanCredentials = false);

      Get.snackbar(
        'Success',
        'Dhan credentials cleared successfully!',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear Dhan credentials: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  Future<void> _clearAlphaVantageKey() async {
    try {
      await ApiConfig.clearAlphaVantageKey();
      setState(() => _hasAlphaVantageKey = false);

      Get.snackbar(
        'Success',
        'Alpha Vantage key cleared successfully!',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear Alpha Vantage key: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  @override
  void dispose() {
    _dhanAccessTokenController.dispose();
    _alphaVantageKeyController.dispose();
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
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.withOpacity(0.1), Colors.purple.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(Icons.key, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'API Configuration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.iosText,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Configure your API keys to enable portfolio sync and real-time data',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.iosSecondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            _buildDhanSection(),

            SizedBox(height: 24),

            _buildAlphaVantageSection(),

            SizedBox(height: 32),

            _buildSetupGuideSection(),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDhanSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.withOpacity(0.1), Colors.teal.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.account_balance, color: Colors.white, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Dhan API',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.iosText,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _hasDhanCredentials ? Colors.green : Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _hasDhanCredentials ? 'Connected' : 'Not Set',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'For fetching your holdings automatically',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.iosSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_hasDhanCredentials)
                  IconButton(
                    onPressed: _clearDhanCredentials,
                    icon: Icon(Icons.delete, color: Colors.red, size: 20),
                  ),
              ],
            ),
          ),

          if (!_hasDhanCredentials) ...[
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _dhanAccessTokenController,
                    label: 'Access Token',
                    hint: 'Enter your Dhan Access Token',
                    icon: Icons.vpn_key,
                    isPassword: true,
                    isVisible: _isDhanTokenVisible,
                    onVisibilityToggle: () {
                      setState(() => _isDhanTokenVisible = !_isDhanTokenVisible);
                    },
                  ),

                  SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveDhanCredentials,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        'Save Dhan Access Token',
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
          ] else ...[
            Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Dhan access token is configured and ready to use!',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlphaVantageSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.withOpacity(0.1), Colors.red.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.orange, Colors.red]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.trending_up, color: Colors.white, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Alpha Vantage API',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.iosText,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _hasAlphaVantageKey ? Colors.green : Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _hasAlphaVantageKey ? 'Connected' : 'Not Set',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'For real-time stock prices and market data',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.iosSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_hasAlphaVantageKey)
                  IconButton(
                    onPressed: _clearAlphaVantageKey,
                    icon: Icon(Icons.delete, color: Colors.red, size: 20),
                  ),
              ],
            ),
          ),

          if (!_hasAlphaVantageKey) ...[
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _alphaVantageKeyController,
                    label: 'API Key',
                    hint: 'Enter your Alpha Vantage API key',
                    icon: Icons.key,
                    isPassword: true,
                    isVisible: _isAlphaKeyVisible,
                    onVisibilityToggle: () {
                      setState(() => _isAlphaKeyVisible = !_isAlphaKeyVisible);
                    },
                  ),

                  SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveAlphaVantageKey,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        'Save Alpha Vantage Key',
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
          ] else ...[
            Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Alpha Vantage API key is configured and ready to use!',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSetupGuideSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.help_outline, color: Colors.white, size: 20),
        ),
        title: Text(
          'Setup Guide',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.iosText,
          ),
        ),
        subtitle: Text(
          'How to get your API keys',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.iosSecondaryText,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dhan API Setup:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.iosText,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '1. Login to your Dhan account\n2. Go to API section in settings\n3. Generate API access token\n4. Copy the access token (Client ID not needed)',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.iosSecondaryText,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Alpha Vantage Setup:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.iosText,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '1. Visit alphavantage.co\n2. Sign up for free account\n3. Get your free API key\n4. Copy and paste the key here',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.iosSecondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.iosText,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !isVisible,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20, color: AppColors.iosGray),
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  size: 20,
                  color: AppColors.iosGray,
                ),
                onPressed: onVisibilityToggle,
              )
                  : null,
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
