import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_theme.dart';

abstract class AppTypography {
  static const TextStyle displayLarge = TextStyle(
    fontFamily: AppTheme.fontFootlight,
    fontSize: 34.0,
    fontWeight: FontWeight.normal,
    height: 1.15,
    color: AppColors.foreground,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: AppTheme.fontFootlight,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: AppColors.foreground,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: AppTheme.fontFootlight,
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    color: AppColors.paper,
  );

  static const TextStyle editorialBody = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.foreground,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.foregroundMuted,
  );

  static const TextStyle monoCaption = TextStyle(
    fontFamily: 'monospace',
    fontSize: 10.0,
    fontWeight: FontWeight.w600,
    color: AppColors.foregroundSubtle,
    letterSpacing: 0.8,
  );
}
