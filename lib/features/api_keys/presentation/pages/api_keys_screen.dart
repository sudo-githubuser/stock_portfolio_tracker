import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/config/api_config.dart';

class ApiKeysScreen extends StatefulWidget {
  @override
  _ApiKeysScreenState createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends State<ApiKeysScreen> with TickerProviderStateMixin {
  final TextEditingController _dhanTokenController = TextEditingController();
  final TextEditingController _alphaKeyController = TextEditingController();

  bool _isDhanTokenVisible = false;
  bool _isAlphaKeyVisible = false;
  bool _isLoading = false;
  bool _showAnimation = false;

  List<String> _alphaVantageKeys = [];

  late AnimationController _lockAnimationController;
  late Animation<double> _lockAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadExistingKeys();
  }

  void _setupAnimations() {
    _lockAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _lockAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _lockAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  Future<void> _loadExistingKeys() async {
    final keys = await ApiConfig.getAlphaVantageKeys();
    final dhanToken = await ApiConfig.getDhanAccessToken();

    setState(() {
      _alphaVantageKeys = keys;
      if (dhanToken != null && dhanToken.isNotEmpty) {
        _dhanTokenController.text = '••••••••••••••••';
      }
    });
  }

  bool get _canSave {
    return _dhanTokenController.text.trim().isNotEmpty ||
        _alphaKeyController.text.trim().isNotEmpty;
  }

  Future<void> _saveCredentials() async {
    setState(() => _isLoading = true);

    try {
      if (_dhanTokenController.text.trim().isNotEmpty &&
          _dhanTokenController.text != '••••••••••••••••') {
        await ApiConfig.saveDhanCredentials('', _dhanTokenController.text.trim());
      }

      if (_alphaKeyController.text.trim().isNotEmpty) {
        await ApiConfig.addAlphaVantageKey(_alphaKeyController.text.trim());
        await _loadExistingKeys();
      }

      _dhanTokenController.clear();
      _alphaKeyController.clear();

      setState(() {
        _isLoading = false;
        _showAnimation = true;
      });

      _lockAnimationController.forward();

      await Future.delayed(Duration(seconds: 2));

      setState(() => _showAnimation = false);
      _lockAnimationController.reset();

      Get.snackbar(
        'Success',
        'API credentials saved securely!',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );

    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        'Failed to save credentials: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  Future<void> _clearDhanToken() async {
    await ApiConfig.clearDhanCredentials();
    _dhanTokenController.clear();
    Get.snackbar('Cleared', 'Dhan token removed', backgroundColor: Colors.orange.withOpacity(0.1));
  }

  Future<void> _removeAlphaKey(String key) async {
    await ApiConfig.removeAlphaVantageKey(key);
    await _loadExistingKeys();
    Get.snackbar('Removed', 'Alpha Vantage key removed', backgroundColor: Colors.orange.withOpacity(0.1));
  }

  @override
  void dispose() {
    _dhanTokenController.dispose();
    _alphaKeyController.dispose();
    _lockAnimationController.dispose();
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: 30),
                _buildDhanTokenField(),
                SizedBox(height: 20),
                _buildAlphaKeyField(),
                SizedBox(height: 30),
                _buildSaveButton(),
                SizedBox(height: 30),
                _buildExistingKeysSection(),
                SizedBox(height: 20),
                _buildHelpSection(),
              ],
            ),
          ),

          if (_showAnimation)
            _buildLockAnimation(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.1), Colors.purple.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(Icons.security, color: Colors.white, size: 28),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure API Configuration',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.iosText,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your credentials are encrypted and stored securely',
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
    );
  }

  Widget _buildDhanTokenField() {
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
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                  child: Text(
                    'Dhan Access Token',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.iosText,
                    ),
                  ),
                ),
                if (_dhanTokenController.text.isNotEmpty)
                  IconButton(
                    onPressed: _clearDhanToken,
                    icon: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _dhanTokenController,
              obscureText: !_isDhanTokenVisible,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Enter your Dhan access token',
                prefixIcon: Icon(Icons.vpn_key, color: AppColors.iosGray),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isDhanTokenVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.iosGray,
                  ),
                  onPressed: () => setState(() => _isDhanTokenVisible = !_isDhanTokenVisible),
                ),
                filled: true,
                fillColor: Colors.grey[50],
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
        ),
      ),
    );
  }

  Widget _buildAlphaKeyField() {
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
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      Text(
                        'Alpha Vantage API Key',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.iosText,
                        ),
                      ),
                      Text(
                        'Add up to ${10 - _alphaVantageKeys.length} more keys',
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
            SizedBox(height: 16),
            TextField(
              controller: _alphaKeyController,
              obscureText: !_isAlphaKeyVisible,
              onChanged: (_) => setState(() {}),
              enabled: _alphaVantageKeys.length < 10,
              decoration: InputDecoration(
                hintText: _alphaVantageKeys.length < 10
                    ? 'Enter Alpha Vantage API key'
                    : 'Maximum 10 keys allowed',
                prefixIcon: Icon(Icons.key, color: AppColors.iosGray),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isAlphaKeyVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.iosGray,
                  ),
                  onPressed: () => setState(() => _isAlphaKeyVisible = !_isAlphaKeyVisible),
                ),
                filled: true,
                fillColor: _alphaVantageKeys.length < 10 ? Colors.grey[50] : Colors.grey,
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
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _canSave && !_isLoading ? _saveCredentials : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _canSave ? AppColors.iosBlue : AppColors.iosGray,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: _canSave ? 4 : 0,
        ),
        child: _isLoading
            ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save, size: 24),
            SizedBox(width: 12),
            Text(
              'Save Credentials',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingKeysSection() {
    if (_alphaVantageKeys.isEmpty) return SizedBox.shrink();

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
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, color: AppColors.iosBlue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Alpha Vantage Keys (${_alphaVantageKeys.length}/10)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.iosText,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...List.generate(_alphaVantageKeys.length, (index) {
              final key = _alphaVantageKeys[index];
              final maskedKey = '${key.substring(0, 8)}${'•' * 8}${key.substring(key.length - 4)}';

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: index == 0 ? Colors.green.withOpacity(0.1) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: index == 0 ? Colors.green : AppColors.iosSeparator,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: index == 0 ? Colors.green : AppColors.iosGray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            maskedKey,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: AppColors.iosText,
                            ),
                          ),
                          if (index == 0)
                            Text(
                              'Primary Key',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeAlphaKey(key),
                      icon: Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.help_outline, color: AppColors.iosBlue),
        title: Text(
          'How to get API keys?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.iosText,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHelpItem('1. Dhan API', 'Login to Dhan → Settings → API → Generate Access Token'),
                SizedBox(height: 12),
                _buildHelpItem('2. Alpha Vantage', 'Visit alphavantage.co → Sign up → Get free API key'),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber[700], size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Alpha Vantage allows 25 requests per day per key. Add multiple keys for unlimited access!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.iosText,
          ),
        ),
        SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.iosSecondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildLockAnimation() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: AnimatedBuilder(
          animation: _lockAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _lockAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.teal],
                  ),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.lock,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
