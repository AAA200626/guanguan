import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// 毛玻璃卡片 — 全局统一质感
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius!),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.cardWhite.withAlpha(180),
            borderRadius: BorderRadius.circular(borderRadius!),
            border: Border.all(
              color: Colors.white.withAlpha(120),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: card,
        ),
      );
    }

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: card,
    );
  }
}
