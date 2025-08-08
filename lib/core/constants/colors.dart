import 'package:flutter/material.dart';

class AppColors {
  // Metallic green gradient - darker at top, lighter in middle, black at bottom
  static const LinearGradient metallicGreenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.4, 0.7, 1.0],
    colors: [
      Color(0xFF1B4332), // Dark metallic green at top
      Color(0xFF2D5A41), // Medium dark green
      Color(0xFF52B788), // Lighter green in middle
      Color(0xFF000000), // Black at bottom
    ],
  );

  // Primary colors - ADDED THESE
  static const Color primary = Color(0xFF007AFF);
  static const Color secondary = Color(0xFF34C759);

  // iOS style colors
  static const Color iosBlue = Color(0xFF007AFF);
  static const Color iosGray = Color(0xFF8E8E93);
  static const Color iosBackground = Color(0xFFF2F2F7);
  static const Color iosCard = Color(0xFFFFFFFF);
  static const Color iosText = Color(0xFF000000);
  static const Color iosSecondaryText = Color(0xFF3C3C43);
  static const Color iosSeparator = Color(0xFFC6C6C8);

  // Tab colors
  static const Color activeTab = Color(0xFF34C759);
  static const Color inactiveTab = Color(0xFF8E8E93);

  // Additional colors
  static const Color background = Color(0xFFF2F2F7);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFFF3B30);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF3C3C43);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
  );
}
