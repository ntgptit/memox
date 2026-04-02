import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/settings/presentation/screens/settings_screen.dart';
import 'package:memox/features/settings/presentation/widgets/settings_placeholder_view.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('settings screen renders placeholder view', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: buildTestApp(home: const SettingsScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPlaceholderView), findsOneWidget);
  });
}
