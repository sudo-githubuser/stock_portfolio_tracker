import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../widgets/side_menu.dart';
import '../../../portfolio/presentation/pages/holdings_summary_screen.dart';
import '../../../portfolio/presentation/pages/current_holdings_screen.dart';
import '../../../portfolio/presentation/pages/analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    HoldingsSummaryScreen(),
    CurrentHoldingsScreen(),
    AnalysisScreen(),
  ];

  final List<String> _tabTitles = [
    AppStrings.holdingsSummary,
    AppStrings.currentHoldings,
    AppStrings.analysis,
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
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.iosBackground,
      drawer: SideMenu(),
      body: SafeArea(
        child: Column(
          children: [
            // Custom iOS style app bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.iosSeparator.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Profile icon for side menu
                  GestureDetector(
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.iosBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: AppColors.iosBlue,
                        size: 20,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: Text(
                        'Portfolio Tracker',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.iosText,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 34),
                ],
              ),
            ),

            // UPDATED: Top tabs with underline indicator, no outline
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Tab titles
                  Row(
                    children: _tabTitles.asMap().entries.map((entry) {
                      int index = entry.key;
                      String title = entry.value;
                      bool isSelected = _currentIndex == index;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _onTabTapped(index),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15, // SAME SIZE FOR ALL
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.iosBlue
                                    : AppColors.iosGray,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Underline indicator
                  Container(
                    height: 2,
                    child: Stack(
                      children: [
                        // Background line (optional light gray)
                        Container(
                          width: double.infinity,
                          height: 2,
                          color: AppColors.iosSeparator.withOpacity(0.3),
                        ),
                        // Active indicator line
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: MediaQuery.of(context).size.width / 3,
                          height: 2,
                          margin: EdgeInsets.only(
                            left: (_currentIndex * MediaQuery.of(context).size.width / 3),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.iosBlue,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Page content with synchronized animation
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: _screens,
              ),
            ),
          ],
        ),
      ),

      // Synchronized Curved bottom navigation
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60,
        items: [
          _buildNavIcon(Icons.pie_chart_outline, 0),
          _buildNavIcon(Icons.account_balance_wallet_outlined, 1),
          _buildNavIcon(Icons.analytics_outlined, 2),
        ],
        color: Colors.blue,
        buttonBackgroundColor: Colors.blueGrey,
        backgroundColor: AppColors.iosBackground,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    return Icon(
      icon,
      size: isSelected ? 26 : 24,
      color: isSelected ? Colors.white : AppColors.iosCard,
    );
  }
}
