import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/folders/presentation/screens/folders_screen.dart';
import 'package:memox/features/folders/presentation/widgets/folders_placeholder_view.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('folders screen renders placeholder view', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: buildTestApp(home: const FoldersScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FoldersPlaceholderView), findsOneWidget);
  });
}
