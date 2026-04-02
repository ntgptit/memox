import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/router/app_router.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/easing_tokens.dart';
import 'package:memox/features/settings/presentation/providers/settings_provider.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

class MemoxApp extends ConsumerWidget {
  const MemoxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final isarAsync = ref.watch(isarProvider);
    final settingsAsync = ref.watch(settingsProvider);

    if (isarAsync.isLoading || settingsAsync.isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final settings = settingsAsync.valueOrNull;

    if (settings == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      locale: settings.locale,
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      theme: AppTheme.light(seedColor: settings.seedColor),
      darkTheme: AppTheme.dark(seedColor: settings.seedColor),
      themeMode: settings.themeMode,
      themeAnimationDuration: DurationTokens.slow,
      themeAnimationCurve: EasingTokens.standard,
      routerConfig: router,
    );
  }
}
