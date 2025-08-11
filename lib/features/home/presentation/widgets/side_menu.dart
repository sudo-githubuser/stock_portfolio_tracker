import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../api_keys/presentation/pages/api_keys_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';

class SideMenu extends StatefulWidget {
  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
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
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header with user info
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.iosBlue,
                    AppColors.iosBlue.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile picture
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => ProfileScreen(),
                          transition: Transition.cupertino);
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // User name and age
                  Text(
                    _userName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),

                  SizedBox(height: 4),

                  if (_userAge.isNotEmpty)
                    Text(
                      'Age: $_userAge',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => ProfileScreen(),
                            transition: Transition.cupertino);
                      },
                      child: Text(
                        'Complete your profile',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.8),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => ProfileScreen(),
                            transition: Transition.cupertino)?.then((_) {
                          _loadUserData(); // Refresh user data when returning
                        });
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.vpn_key_outlined,
                      title: 'API Keys',
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => ApiKeysScreen(),
                            transition: Transition.cupertino);
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: AppStrings.settings,
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to settings
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.login_outlined,
                      title: AppStrings.loginSignup,
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to login/signup
                      },
                    ),

                    Divider(
                      color: AppColors.iosSeparator.withOpacity(0.5),
                      height: 32,
                    ),

                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: AppStrings.about,
                      onTap: () {
                        Navigator.pop(context);
                        // Show about dialog
                        _showAboutDialog();
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: AppStrings.help,
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to help
                      },
                    ),
                  ],
                ),
              ),
            ),

            // App version
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.iosGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.iosBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.iosBlue,
                size: 18,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.iosText,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.iosGray,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About Portfolio Tracker'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0'),
            SizedBox(height: 8),
            Text('A comprehensive portfolio tracking app with Dhan integration and Alpha Vantage price feeds.'),
            SizedBox(height: 16),
            Text('Features:', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('• Live stock prices'),
            Text('• Dhan holdings sync'),
            Text('• Manual stock addition'),
            Text('• Portfolio analytics'),
            Text('• Secure API key storage'),
          ],
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
}
