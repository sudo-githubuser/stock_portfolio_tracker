// import 'package:flutter/material.dart';
// import '../../../../core/constants/colors.dart';
// import '../../../portfolio/presentation/pages/current_holdings_screen.dart';
// import '../../../settings/presentation/pages/settings_screen.dart';
// import 'analysis_screen.dart';
// import 'holdings_summary_screen.dart';
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;
//
//   final List<Widget> _screens = [
//     HoldingsSummaryScreen(), // Home
//     CurrentHoldingsScreen(), // Holdings
//     AnalysisScreen(), // Analysis
//     SettingsScreen(), // Settings
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               offset: Offset(0, -2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(25),
//             topRight: Radius.circular(25),
//           ),
//           child: BottomNavigationBar(
//             currentIndex: _currentIndex,
//             onTap: (index) => setState(() => _currentIndex = index),
//             type: BottomNavigationBarType.fixed,
//             backgroundColor: Colors.white,
//             selectedItemColor: AppColors.iosBlue,
//             unselectedItemColor: AppColors.iosGray,
//             selectedFontSize: 12,
//             unselectedFontSize: 12,
//             elevation: 0,
//             items: [
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.home_outlined),
//                 activeIcon: Icon(Icons.home),
//                 label: 'Home',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.pie_chart_outline),
//                 activeIcon: Icon(Icons.pie_chart),
//                 label: 'Holdings',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.analytics_outlined),
//                 activeIcon: Icon(Icons.analytics),
//                 label: 'Analysis',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.settings_outlined),
//                 activeIcon: Icon(Icons.settings),
//                 label: 'Settings',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
