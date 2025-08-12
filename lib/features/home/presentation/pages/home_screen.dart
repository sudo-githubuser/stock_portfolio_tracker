import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../../../../core/constants/colors.dart';
import '../../../portfolio/presentation/pages/analysis_screen.dart';
import '../../../portfolio/presentation/pages/current_holdings_screen.dart';

import '../../../portfolio/presentation/pages/holdings_summary_screen.dart';
import '../../../settings/presentation/pages/settings_screen.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    HoldingsSummaryScreen(), // Home
    CurrentHoldingsScreen(), // Holdings
    AnalysisScreen(), // Analysis
    SettingsScreen(), // Settings
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Animate to the selected page
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    return Icon(
      icon,
      size: 28,
      color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 65,
        items: [
          _buildNavIcon(Icons.home_outlined, 0),
          _buildNavIcon(Icons.pie_chart_outline, 1),
          _buildNavIcon(Icons.analytics_outlined, 2),
          _buildNavIcon(Icons.settings_outlined, 3),
        ],
        color: AppColors.iosBlue,
        buttonBackgroundColor: Colors.blueGrey,
        backgroundColor: AppColors.iosBackground,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        onTap: _onTabTapped,
      ),
    );
  }
}
