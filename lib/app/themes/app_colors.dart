import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors (Green from Figma design)
  static const Color primary = Color(0xFF00BF41);
  static const Color primaryLight = Color(0xFF4CD67A);
  static const Color primaryDark = Color(0xFF009933);

  // Secondary Colors
  static const Color secondary = Color(0xFF7C4DFF);
  static const Color secondaryLight = Color(0xFFB47CFF);
  static const Color secondaryDark = Color(0xFF3F1DCB);

  // Accent Colors
  static const Color accent = Color(0xFFE8B4B4);
  static const Color accentDark = Color(0xFFD49292);

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Icon Colors
  static const Color iconPrimary = Color(0xFF616161);
  static const Color iconSecondary = Color(0xFF9E9E9E);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [accentDark, accent],
  );

  // Stats Card Colors
  static const Color profileViews = Color(0xFF7C4DFF);
  static const Color sentInterest = Color(0xFF4CAF50);
  static const Color receivedInterest = Color(0xFFFF7043);
  static const Color acceptedProfile = Color(0xFF26A69A);

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ==================== Dark Mode Colors ====================

  // Dark Background Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);

  // Dark Text Colors
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextHint = Color(0xFF757575);

  // Dark Border Colors
  static const Color darkBorder = Color(0xFF424242);
  static const Color darkDivider = Color(0xFF303030);

  // Dark Icon Colors
  static const Color darkIconPrimary = Color(0xFFBDBDBD);
  static const Color darkIconSecondary = Color(0xFF757575);

  // Dark Shimmer Colors
  static const Color darkShimmerBase = Color(0xFF2C2C2C);
  static const Color darkShimmerHighlight = Color(0xFF3D3D3D);
}
