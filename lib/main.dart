import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/constants/colors.dart';
import 'features/welcome/presentation/pages/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set iOS style status bar
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Portfolio Tracker App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // iOS inspired theme
        primaryColor: AppColors.iosBlue,
        scaffoldBackgroundColor: AppColors.iosBackground,
        fontFamily: 'SF Pro Text', // iOS system font (or use default)

        // App bar theme
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.iosText,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),

        // Card theme
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Text theme with iOS typography
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: AppColors.iosText,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.iosText,
          ),
          bodyLarge: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.iosText,
          ),
          bodyMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.iosSecondaryText,
          ),
        ),

        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WelcomeScreen(),
    );
  }
}
