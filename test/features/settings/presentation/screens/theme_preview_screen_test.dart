import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/settings/presentation/screens/theme_preview_screen.dart';
import 'package:memox/features/settings/presentation/widgets/theme_preview/theme_components_section.dart';
import 'package:memox/features/settings/presentation/widgets/theme_preview/theme_mode_selector.dart';
import 'package:memox/features/settings/presentation/widgets/theme_preview/theme_typography_section.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('theme preview screen renders preview sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: buildTestApp(home: const ThemePreviewScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ThemeModeSelector), findsOneWidget);
    expect(find.byType(ThemeTypographySection), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byType(ThemeComponentsSection),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ThemeComponentsSection), findsOneWidget);
  });
}
