import 'package:flutter/material.dart';
import 'colors.dart';

/// 罐罐 App — 字体层级
class AppTypography {
  AppTypography._();

  // 使用系统默认字体（Roboto / SF Pro）

  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
    height: 1.4,
  );

  /// 金额大字 — 用于总资产展示
  static const TextStyle amount = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// Material 3 TextTheme
  static TextTheme get textTheme => const TextTheme(
        displayLarge: h1,
        headlineMedium: h2,
        titleLarge: h3,
        bodyLarge: body,
        bodyMedium: caption,
      );
}
