import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/study/presentation/screens/study_screen.dart';
import 'package:memox/features/study/presentation/widgets/study_placeholder_view.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('study screen renders placeholder view', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: buildTestApp(home: const StudyScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StudyPlaceholderView), findsOneWidget);
  });
}
