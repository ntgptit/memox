import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/shared/widgets/feedback/app_refresh_indicator.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('AppRefreshIndicator triggers refresh callback on pull', (
    tester,
  ) async {
    var refreshed = false;

    await tester.pumpWidget(
      buildTestApp(
        home: SizedBox(
          height: 320,
          child: AppRefreshIndicator(
            onRefresh: () async => refreshed = true,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 640, child: Text('Content'))],
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(refreshed, isTrue);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('AppRefreshScrollView stays refreshable for empty content', (
    tester,
  ) async {
    var refreshed = false;

    await tester.pumpWidget(
      buildTestApp(
        home: SizedBox(
          height: 320,
          child: AppRefreshScrollView(
            onRefresh: () async => refreshed = true,
            child: const Center(child: Text('Empty')),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(refreshed, isTrue);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });
}
