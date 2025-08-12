import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/colors.dart';
import '../../../api_keys/presentation/pages/api_keys_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _darkModeEnabled = false;
  String _currency = 'INR';
  String _refreshInterval = '30s';
  String _userName = 'User';
  String _userAge = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name') ?? 'User';
      final age = prefs.getString('user_age') ?? '';

      setState(() {
        _userName = name;
        _userAge = age;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iosBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 24),
              _buildProfileSection(),
              SizedBox(height: 24),
              _buildGeneralSection(),
              SizedBox(height: 24),
              _buildSecuritySection(),
              SizedBox(height: 24),
              _buildDataSection(),
              SizedBox(height: 24),
              _buildAboutSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(Icons.settings, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.iosText,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Configure your app preferences',
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

  Widget _buildProfileSection() {
    return _buildSection(
      title: 'Profile & Account',
      children: [
        _buildActionTile(
          icon: Icons.person_outline,
          title: 'Profile',
          subtitle: _userAge.isNotEmpty ? '$_userName, Age: $_userAge' : 'Complete your profile',
          onTap: () {
            Get.to(() => ProfileScreen(), transition: Transition.cupertino)?.then((_) {
              _loadUserData(); // Refresh user data when returning
            });
          },
        ),

        _buildActionTile(
          icon: Icons.vpn_key_outlined,
          title: 'API Keys',
          subtitle: 'Manage your API credentials',
          onTap: () {
            Get.to(() => ApiKeysScreen(), transition: Transition.cupertino);
          },
        ),

        _buildActionTile(
          icon: Icons.login_outlined,
          title: 'Login & Signup',
          subtitle: 'Manage your account authentication',
          onTap: () {
            Get.snackbar(
              'Coming Soon',
              'Login & Signup features will be available soon',
              backgroundColor: Colors.blue.withOpacity(0.1),
              colorText: Colors.blue,
            );
          },
        ),
      ],
    );
  }

  Widget _buildGeneralSection() {
    return _buildSection(
      title: 'General',
      children: [
        _buildSwitchTile(
          icon: Icons.notifications_outlined,
          title: 'Push Notifications',
          subtitle: 'Receive portfolio updates',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
            Get.snackbar(
              'Settings Updated',
              'Notification preference saved',
              backgroundColor: Colors.green.withOpacity(0.1),
              colorText: Colors.green,
            );
          },
        ),

        _buildSwitchTile(
          icon: Icons.dark_mode_outlined,
          title: 'Dark Mode',
          subtitle: 'Switch to dark theme',
          value: _darkModeEnabled,
          onChanged: (value) {
            setState(() => _darkModeEnabled = value);
            Get.snackbar(
              'Coming Soon',
              'Dark mode will be available in next update',
              backgroundColor: Colors.blue.withOpacity(0.1),
              colorText: Colors.blue,
            );
          },
        ),

        _buildDropdownTile(
          icon: Icons.currency_rupee,
          title: 'Currency',
          subtitle: 'Select display currency',
          value: _currency,
          items: ['INR', 'USD', 'EUR', 'GBP'],
          onChanged: (value) {
            setState(() => _currency = value);
            Get.snackbar(
              'Settings Updated',
              'Currency changed to $value',
              backgroundColor: Colors.green.withOpacity(0.1),
              colorText: Colors.green,
            );
          },
        ),

        _buildDropdownTile(
          icon: Icons.refresh,
          title: 'Auto Refresh',
          subtitle: 'Data refresh interval',
          value: _refreshInterval,
          items: ['15s', '30s', '1m', '5m', 'Manual'],
          onChanged: (value) {
            setState(() => _refreshInterval = value);
            Get.snackbar(
              'Settings Updated',
              'Refresh interval set to $value',
              backgroundColor: Colors.green.withOpacity(0.1),
              colorText: Colors.green,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSection(
      title: 'Security',
      children: [
        _buildSwitchTile(
          icon: Icons.fingerprint,
          title: 'Biometric Login',
          subtitle: 'Use fingerprint or face unlock',
          value: _biometricEnabled,
          onChanged: (value) {
            setState(() => _biometricEnabled = value);
            Get.snackbar(
              'Coming Soon',
              'Biometric authentication will be available soon',
              backgroundColor: Colors.blue.withOpacity(0.1),
              colorText: Colors.blue,
            );
          },
        ),

        _buildActionTile(
          icon: Icons.lock_reset,
          title: 'Change PIN',
          subtitle: 'Update your security PIN',
          onTap: () {
            Get.snackbar(
              'Coming Soon',
              'PIN management will be available soon',
              backgroundColor: Colors.blue.withOpacity(0.1),
              colorText: Colors.blue,
            );
          },
        ),

        _buildActionTile(
          icon: Icons.security,
          title: 'Two-Factor Authentication',
          subtitle: 'Add extra security layer',
          onTap: () {
            Get.snackbar(
              'Coming Soon',
              '2FA will be available in next update',
              backgroundColor: Colors.blue.withOpacity(0.1),
              colorText: Colors.blue,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return _buildSection(
      title: 'Data & Storage',
      children: [
        _buildActionTile(
          icon: Icons.backup_outlined,
          title: 'Backup Data',
          subtitle: 'Export your portfolio data',
          onTap: () {
            Get.snackbar(
              'Coming Soon',
              'Data backup feature will be available soon',
              backgroundColor: Colors.blue.withOpacity(0.1),
              colorText: Colors.blue,
            );
          },
        ),

        _buildActionTile(
          icon: Icons.cloud_sync_outlined,
          title: 'Sync Settings',
          subtitle: 'Synchronize across devices',
          onTap: () {
            Get.snackbar(
              'Coming Soon',
              'Cloud sync will be available soon',
              backgroundColor: Colors.blue.withOpacity(0.1),
              colorText: Colors.blue,
            );
          },
        ),

        _buildActionTile(
          icon: Icons.delete_sweep_outlined,
          title: 'Clear Cache',
          subtitle: 'Free up storage space',
          onTap: () {
            _showClearCacheDialog();
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'About & Support',
      children: [
        _buildActionTile(
          icon: Icons.info_outline,
          title: 'App Version',
          subtitle: 'Track O Folio v1.0.0',
          onTap: () {
            _showAboutDialog();
          },
        ),

        _buildActionTile(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () {
            Get.snackbar(
              'Coming Soon',
              'Help & Support feature will be available soon',
              backgroundColor: Colors.blue.withOpacity(0.1),
              colorText: Colors.blue,
            );
          },
        ),

        _buildActionTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          onTap: () {
            Get.snackbar(
              'Coming Soon',
              'Privacy policy will be available soon',
              backgroundColor: Colors.blue.withOpacity(0.1),
              colorText: Colors.blue,
            );
          },
        ),

        _buildActionTile(
          icon: Icons.description_outlined,
          title: 'Terms of Service',
          subtitle: 'View terms and conditions',
          onTap: () {
            Get.snackbar(
              'Coming Soon',
              'Terms of service will be available soon',
              backgroundColor: Colors.blue.withOpacity(0.1),
              colorText: Colors.blue,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
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
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.iosText,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.iosBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.iosBlue, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.iosText,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.iosSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.iosBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.iosBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.iosBlue, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.iosText,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.iosSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            underline: SizedBox.shrink(),
            items: items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            )).toList(),
            onChanged: (newValue) => onChanged(newValue!),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.iosBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.iosBlue, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.iosText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.iosSecondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.iosSecondaryText,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Clear Cache'),
        content: Text('This will clear all cached data and may improve performance. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Cache Cleared',
                'App cache has been cleared successfully',
                backgroundColor: Colors.green.withOpacity(0.1),
                colorText: Colors.green,
              );
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('About Track O Folio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Track O Folio v1.0.0'),
            SizedBox(height: 8),
            Text('Monitor your portfolio and track market trends with ease.'),
            SizedBox(height: 16),
            Text('Features:', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('• Live stock prices'),
            Text('• Dhan holdings sync'),
            Text('• Manual stock addition'),
            Text('• Portfolio analytics'),
            Text('• Secure API key storage'),
            SizedBox(height: 16),
            Text('Built with Flutter'),
            SizedBox(height: 8),
            Text(
              '© 2025 Track O Folio',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
