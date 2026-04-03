import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/responsive/screen_type.dart';
import 'package:memox/core/router/app_router.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/easing_tokens.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/presentation/providers/settings_provider.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/shared/widgets/feedback/loading_indicator.dart';

class MemoxApp extends ConsumerWidget {
  const MemoxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.asData?.value ?? AppSettings.defaults;

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appName,
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
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final content = child ?? const SizedBox.shrink();
        final responsiveContent = MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(
              ScreenType.of(context).textScaleFactor,
            ),
          ),
          child: content,
        );

        if (!settingsAsync.isLoading) {
          return responsiveContent;
        }

        return Stack(
          children: [
            responsiveContent,
            Positioned.fill(
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surface,
                child: const LoadingIndicator(),
              ),
            ),
          ],
        );
      },
    );
  }
}
