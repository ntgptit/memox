import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/responsive/screen_type.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/features/statistics/domain/value_objects/date_range.dart';
import 'package:memox/features/statistics/presentation/widgets/statistics_period_tabs.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

void main() {
  testWidgets(
    'StatisticsPeriodTabs stays stable on compact Vietnamese layouts',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          theme: AppTheme.light(),
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                ScreenType.of(context).textScaleFactor,
              ),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
          home: Scaffold(
            body: StatisticsPeriodTabs(
              selectedRange: DateRange.week,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Toàn thời gian'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
