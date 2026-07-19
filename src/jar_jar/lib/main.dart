import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'theme/colors.dart';
import 'theme/typography.dart';
import 'screens/main_shell.dart';
import 'utils/database_helper.dart';
import 'utils/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化时区
  tz_data.initializeTimeZones();
  try {
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
  } catch (_) {}

  // 初始化数据库
  try {
    await DatabaseHelper.instance.database;
  } catch (e) {
    debugPrint('DB: $e');
  }

  // 通知后续通过设置页手动开启
  try {
    await NotificationHelper.init();
  } catch (e) {
    debugPrint('Notify: $e');
  }

  runApp(const ProviderScope(child: JarJarApp()));
}

class JarJarApp extends StatelessWidget {
  const JarJarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '罐罐',
      debugShowCheckedModeBanner: false,
      scrollBehavior: _PlatformScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.cardWhite,
        ),
        useMaterial3: true,
        textTheme: AppTypography.textTheme,
        scaffoldBackgroundColor: AppColors.backgroundGrey,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.cardWhite.withAlpha(200),
          foregroundColor: AppColors.textDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTypography.h3,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardWhite.withAlpha(180),
          elevation: 1,
          shadowColor: AppColors.primaryLight.withAlpha(40),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withAlpha(80), width: 0.5),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.cardWhite,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textLight,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const MainShell(),
    );
  }
}

/// iOS / Android 自适应滚动行为
class _PlatformScrollBehavior extends MaterialScrollBehavior {
  const _PlatformScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (Platform.isIOS) return child;
    return super.buildScrollbar(context, child, details);
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return Platform.isIOS
        ? const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics())
        : super.getScrollPhysics(context);
  }
}
