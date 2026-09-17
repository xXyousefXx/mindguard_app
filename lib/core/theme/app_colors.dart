import 'package:flutter/material.dart';

/// Single source of truth for colours, taken from the Figma design.
/// Never hardcode a Color literal inside a widget - add it here instead.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF089B85);
  static const Color primaryDark = Color(0xFF00806E);
  static const Color primaryLight = Color(0xFF3FBBA6);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color background = Color(0xFFF0F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFE8F4F1);

  static const Color textPrimary = Color(0xFF1B2A27);
  static const Color textSecondary = Color(0xFF6B807B);

  static const Color success = Color(0xFF2FAE60);
  static const Color warning = Color(0xFFF2A03D);
  static const Color danger = Color(0xFFE0523E);
  static const Color info = Color(0xFF3E7BE0);
  static const Color purple = Color(0xFF8B5CF6);

  static const Color successSoft = Color(0xFFE3F5E8);
  static const Color warningSoft = Color(0xFFFDF0DF);
  static const Color dangerSoft = Color(0xFFFBE7E4);
  static const Color infoSoft = Color(0xFFE6EFFC);
  static const Color purpleSoft = Color(0xFFF1E9FE);

  static const Color border = Color(0xFFE2EDEA);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0BA793), Color(0xFF039C86)],
  );
}
