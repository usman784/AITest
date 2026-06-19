import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_flow/core/constants/app_strings.dart';
import 'package:arrow_flow/core/di/providers.dart';
import 'package:arrow_flow/core/theme/app_theme.dart';
import 'package:arrow_flow/core/theme/theme_notifier.dart';

/// Root widget of the Arrow Flow app.
///
/// Bootstraps [ScreenUtil], reads the active theme from [themeProvider], and
/// passes the [GoRouter] instance from [routerProvider] to [MaterialApp.router].
class ArrowFlowApp extends ConsumerWidget {
  const ArrowFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    final lightTheme = AppTheme.getTheme(
      themeState.visualStyle,
      Brightness.light,
    );
    final darkTheme = AppTheme.getTheme(
      themeState.visualStyle,
      Brightness.dark,
    );

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeState.themeMode,
        routerConfig: router,
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
      ),
    );
  }
}

/// Async initialiser that builds the [ProviderScope] overrides before running
/// the app.
///
/// Called from [main] — not a widget itself.
Future<ProviderScope> buildProviderScope() async {
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const ArrowFlowApp(),
  );
}
