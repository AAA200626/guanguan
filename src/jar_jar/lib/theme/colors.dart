import 'package:flutter/material.dart';

/// 罐罐 App — 薄荷青柠马卡龙色板
class AppColors {
  AppColors._();

  // 主色 — 薄荷绿
  static const Color primary = Color(0xFF7DCFB6);
  static const Color primaryLight = Color(0xFFA8E6CF);
  static const Color primaryUltraLight = Color(0xFFD6F5E8);

  // 辅色 — 杏色暖调点缀（金币、奖章）
  static const Color accent = Color(0xFFFFE8B3);

  // 中性色
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color backgroundGrey = Color(0xFFF5F5F5);

  // 文字色
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textLight = Color(0xFF95A5A6);

  // 功能色
  static const Color success = Color(0xFF7DCFB6);
  static const Color warning = Color(0xFFFFD93D);
  static const Color error = Color(0xFFFF6B6B);

  // 难度色
  static const Color difficultyEasy = Color(0xFFA8E6CF);
  static const Color difficultyMedium = Color(0xFFFFE8B3);
  static const Color difficultyHard = Color(0xFFFFB3B3);

  // Material 主题色 swatch
  static const MaterialColor primarySwatch = MaterialColor(0xFF7DCFB6, {
    50: Color(0xFFD6F5E8),
    100: Color(0xFFA8E6CF),
    200: Color(0xFF7DCFB6),
    300: Color(0xFF5CBF9E),
    400: Color(0xFF3EAF88),
    500: Color(0xFF7DCFB6),
    600: Color(0xFF6BBFA3),
    700: Color(0xFF5AAD90),
    800: Color(0xFF489B7D),
    900: Color(0xFF367A6A),
  });
}
