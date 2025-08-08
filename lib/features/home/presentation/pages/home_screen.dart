import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../portfolio/presentation/pages/holdings_summary_screen.dart';
import '../widgets/side_menu.dart';
import '../../../portfolio/presentation/pages/current_holdings_screen.dart';
import '../../../portfolio/presentation/pages/analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;
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
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

                  SizedBox(width: 34), // Balance the layout
                ],
              ),
            ),

            // Top tabs (iOS style segmented control look)
            Container(
              margin: EdgeInsets.all(16),
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
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.iosBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.iosGray,
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                tabs: _tabTitles.map((title) => Tab(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(title),
                    ),
                  ),
                )).toList(),
              ),
            ),

            // Tab content with smooth page transitions
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _screens,
              ),
            ),
          ],
        ),
      ),

      // Curved bottom navigation with smooth animations
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60,
        items: [
          _buildNavIcon(Icons.pie_chart_outline, 0),
          _buildNavIcon(Icons.account_balance_wallet_outlined, 1),
          _buildNavIcon(Icons.analytics_outlined, 2),
        ],
        color: Colors.white,
        buttonBackgroundColor: AppColors.iosBlue,
        backgroundColor: AppColors.iosBackground,
        animationCurve: Curves.easeInOutCubic, // Smooth wavy animation
        animationDuration: Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _tabController.animateTo(index);
          });
        },
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    return Icon(
      icon,
      size: isSelected ? 26 : 24,
      color: isSelected ? Colors.white : AppColors.iosGray,
    );
  }
}
