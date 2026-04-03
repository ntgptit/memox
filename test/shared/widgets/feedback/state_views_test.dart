import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/shared/widgets/feedback/offline_state_view.dart';
import 'package:memox/shared/widgets/feedback/unauthorized_state_view.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('OfflineStateView renders default localized content', (
    tester,
  ) async {
    var retried = false;

    await tester.pumpWidget(
      buildTestApp(home: OfflineStateView(onRetry: () => retried = true)),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    expect(find.text("You're offline"), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();

    expect(retried, isTrue);
  });

  testWidgets('UnauthorizedStateView renders default localized content', (
    tester,
  ) async {
    var signedIn = false;

    await tester.pumpWidget(
      buildTestApp(
        home: UnauthorizedStateView(
          onSignInAgain: () => signedIn = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.lock_clock_outlined), findsOneWidget);
    expect(find.text('Session expired'), findsOneWidget);
    expect(find.text('Sign in again'), findsOneWidget);

    await tester.tap(find.text('Sign in again'));
    await tester.pump();

    expect(signedIn, isTrue);
  });
}
