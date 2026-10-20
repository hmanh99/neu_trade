import 'package:flutter/material.dart';

class ColorConstants {
  ColorConstants._();

  // Basic & Utility Colors
  static const white = Colors.white;
  static const black = Colors.black;
  static const transparent = Colors.transparent;
  static const grey = Color(0xFF64748B);
  static const blue = Color(0xFF2563EB);
  static const green = Color(0xFF10B981);
  static const red = Color(0xFFEF4444);
  static const yellow = Color(0xFFF59E0B);
  static const orange = Color(0xFFF97316);

  // Primary & Secondary Brand Colors (NEU Navy & Royal Blue)
  static const primaryColor = Color(0xFF1D4ED8);
  static const primaryDark = Color(0xFF1E3A8A);
  static const primaryLight = Color(0xFF3B82F6);
  static const primaryLightBg = Color(0xFFEFF6FF);
  static const accentColor = Color(0xFF0284C7);
  static const accentLightBg = Color(0xFFF0FDF4);

  // Slate / Modern Grey Shades
  static const greyShade50 = Color(0xFFF8FAFC);
  static const greyShade100 = Color(0xFFF1F5F9);
  static const greyShade200 = Color(0xFFE2E8F0);
  static const greyShade300 = Color(0xFFCBD5E1);
  static const greyShade400 = Color(0xFF94A3B8);
  static const greyShade500 = Color(0xFF64748B);
  static const greyShade600 = Color(0xFF475569);
  static const greyShade700 = Color(0xFF334155);
  static const greyShade800 = Color(0xFF1E293B);
  static const greyShade900 = Color(0xFF0F172A);

  // White Variations
  static const white24 = Colors.white24;
  static const white38 = Colors.white38;
  static const white54 = Colors.white54;
  static const white70 = Colors.white70;

  // Black Variations
  static const black12 = Colors.black12;
  static const black26 = Colors.black26;
  static const black38 = Colors.black38;
  static const black45 = Colors.black45;
  static const black54 = Colors.black54;
  static const black87 = Colors.black87;

  // Red & Error Shades
  static const redAccent = Color(0xFFF43F5E);
  static const redShade50 = Color(0xFFFEF2F2);
  static const redShade100 = Color(0xFFFEE2E2);
  static const redShade200 = Color(0xFFFECACA);
  static const redShade400 = Color(0xFFF87171);
  static const redShade700 = Color(0xFFB91C1C);

  // Green & Success Shades
  static const greenShade50 = Color(0xFFECFDF5);
  static const greenShade100 = Color(0xFFD1FAE5);
  static const greenShade600 = Color(0xFF059669);
  static const greenShade700 = Color(0xFF047857);

  // Blue Shades
  static const blueShade50 = Color(0xFFEFF6FF);
  static const blueShade100 = Color(0xFFDBEAFE);
  static const blueShade700 = Color(0xFF1D4ED8);

  // Orange & Warning Shades
  static const orangeShade50 = Color(0xFFFFFBEB);
  static const orangeShade100 = Color(0xFFFEF3C7);
  static const orangeShade700 = Color(0xFFB45309);

  // Semantic UI Colors
  static const cardColor = Colors.white;
  static const dividerColor = Color(0xFFF1F5F9);
  static const borderLightColor = Color(0xFFE2E8F0);
  static const successColor = Color(0xFF10B981);
  static const successLightColor = Color(0xFFECFDF5);
  static const warningColor = Color(0xFFF59E0B);
  static const warningLightColor = Color(0xFFFFFBEB);
  static const errorLightColor = Color(0xFFFEF2F2);

  // Base
  static const backgroundColor = Color(0xFFF8FAFC);
  static const textPrimaryColor = Color(0xFF0F172A);
  static const textSecondaryColor = Color(0xFF64748B);
  static const textHighlightColor = Color(0xFF2563EB);
  static const iconColor = Color(0xFF1D4ED8);

  // AppBar
  static const appBarBackgroundColor = Colors.white;
  static const appBarForegroundColor = Color(0xFF0F172A);

  // Bottom navigation
  static const bottomNavBackgroundColor = Colors.white;
  static const bottomNavSelectedColor = Color(0xFF1D4ED8);
  static const bottomNavUnselectedColor = Color(0xFF94A3B8);

  // SnackBar
  static const snackBarBackgroundColor = Color(0xFF0F172A);
  static const snackBarTextColor = Colors.white;
  static const snackBarActionColor = Color(0xFF60A5FA);
  static const snackBarSuccessColor = Color(0xFF059669);
  static const snackBarFailedColor = Color(0xFFDC2626);

  // Dialog
  static const dialogBackgroundColor = Colors.white;

  // Buttons & Actions
  static const buttonColor = Color(0xFF1D4ED8);
  static const buttonTextColor = Colors.white;
  static const deleteActionColor = Color(0xFFEF4444);
  static const socialBorderColor = Color(0xFFE2E8F0);

  // Error States
  static const errorColor = Color(0xFFEF4444);
  
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
  );

  // Shadows
  static const softShadow = [
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
    BoxShadow(
      color: Color(0x050F172A),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];

  static const elevatedShadow = [
    BoxShadow(
      color: Color(0x0F0F172A),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];

  static const glowShadow = [
    BoxShadow(
      color: Color(0x281D4ED8),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
}