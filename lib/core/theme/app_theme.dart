import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTheme {
  static const String fontFootlight = 'FootlightMTLight';

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.straw,
        secondary: AppColors.leaf,
        tertiary: AppColors.accentOrange,
        error: AppColors.error,
        onSurface: AppColors.foreground,
        onPrimary: AppColors.background,
        onSecondary: AppColors.background,
      ),
      fontFamilyFallback: const ['Roboto', 'sans-serif'],
      textTheme: const TextTheme(
        // Editorial Display / Headings in Footlight MT Light
        displayLarge: TextStyle(
          fontFamily: fontFootlight,
          fontSize: 38.0,
          fontWeight: FontWeight.normal,
          height: 1.15,
          color: AppColors.foreground,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFootlight,
          fontSize: 30.0,
          fontWeight: FontWeight.normal,
          height: 1.2,
          color: AppColors.foreground,
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFootlight,
          fontSize: 24.0,
          fontWeight: FontWeight.normal,
          height: 1.25,
          color: AppColors.foreground,
        ),
        headlineLarge: TextStyle(
          fontFamily: fontFootlight,
          fontSize: 22.0,
          fontWeight: FontWeight.normal,
          color: AppColors.paper,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFootlight,
          fontSize: 19.0,
          fontWeight: FontWeight.normal,
          color: AppColors.paper,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFootlight,
          fontSize: 17.0,
          fontWeight: FontWeight.normal,
          color: AppColors.paper,
        ),
        
        // Scientific / Body / Technical readouts in Sans-serif
        titleLarge: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
          letterSpacing: 0.2,
        ),
        titleMedium: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
          letterSpacing: 0.1,
        ),
        titleSmall: TextStyle(
          fontSize: 13.0,
          fontWeight: FontWeight.w500,
          color: AppColors.foregroundMuted,
          letterSpacing: 0.3,
        ),
        bodyLarge: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.normal,
          height: 1.55,
          color: AppColors.foreground,
        ),
        bodyMedium: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.normal,
          height: 1.5,
          color: AppColors.foregroundMuted,
        ),
        bodySmall: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.normal,
          height: 1.4,
          color: AppColors.foregroundSubtle,
        ),
        labelLarge: TextStyle(
          fontSize: 13.0,
          fontWeight: FontWeight.w600,
          color: AppColors.paper,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.w500,
          color: AppColors.straw,
          letterSpacing: 0.8,
        ),
        labelSmall: TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.w600,
          color: AppColors.foregroundSubtle,
          letterSpacing: 1.0,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.paper),
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFootlight,
          fontSize: 20.0,
          color: AppColors.foreground,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Editorial crisp ruled borders
          side: BorderSide(color: AppColors.border, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.straw, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.error),
        ),
        hintStyle: TextStyle(
          fontSize: 13.5,
          color: AppColors.foregroundSubtle,
        ),
        labelStyle: TextStyle(
          fontSize: 13.0,
          color: AppColors.foregroundMuted,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.straw,
          foregroundColor: AppColors.background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.paper,
          side: const BorderSide(color: AppColors.borderBright, width: 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: const TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1.0,
        space: 1.0,
      ),
    );
  }
}

