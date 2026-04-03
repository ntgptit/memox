import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/app_fab.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('AppScaffold adds bottom breathing room without bottom nav', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildTestApp(
        home: AppScaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Container(key: const Key('bottom-box'), height: 40),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boxRect = tester.getRect(find.byKey(const Key('bottom-box')));
    expect(844 - boxRect.bottom, closeTo(SpacingTokens.xl, 0.01));
  });

  testWidgets('AppScaffold reserves extra bottom space when a fab is present', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildTestApp(
        home: AppScaffold(
          fab: AppFab(icon: Icons.add_outlined, onTap: () {}),
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Container(key: const Key('fab-bottom-box'), height: 40),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boxRect = tester.getRect(find.byKey(const Key('fab-bottom-box')));
    expect(
      844 - boxRect.bottom,
      closeTo(SizeTokens.fabSize + SpacingTokens.lg, 0.01),
    );
  });

  testWidgets('AppScaffold can disable bottom breathing room', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildTestApp(
        home: AppScaffold(
          applyBottomPadding: false,
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Container(key: const Key('flush-bottom-box'), height: 40),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boxRect = tester.getRect(find.byKey(const Key('flush-bottom-box')));
    expect(844 - boxRect.bottom, closeTo(0, 0.01));
  });

  testWidgets('AppScaffold forwards drawer and endDrawer to Scaffold', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const AppScaffold(
          drawer: Drawer(),
          endDrawer: Drawer(),
          body: SizedBox.shrink(),
        ),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.drawer, isNotNull);
    expect(scaffold.endDrawer, isNotNull);
  });
}
