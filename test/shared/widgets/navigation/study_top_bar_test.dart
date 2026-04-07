import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/navigation/study_top_bar.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('StudyTopBar aligns meta content to responsive screen padding', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(700, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildTestApp(
        home: const Scaffold(
          appBar: StudyTopBar(
            title: 'Review',
            current: 3,
            total: 12,
            subtitle: 'Round summary',
            onClose: _noop,
            showProgress: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final subtitleRect = tester.getRect(find.text('Round summary'));

    expect(subtitleRect.left, closeTo(SpacingTokens.xl, 0.01));
  });
}

void _noop() {}
