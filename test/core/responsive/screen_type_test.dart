import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/responsive/screen_type.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

void main() {
  testWidgets('screen type resolves compact values', (tester) async {
    ScreenType? screenType;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: Builder(
          builder: (context) {
            screenType = ScreenType.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(screenType, ScreenType.compact);
    expect(screenType!.screenPadding, SpacingTokens.lg);
    expect(screenType!.gridColumns, 1);
    expect(screenType!.textScaleFactor, 1);
  });

  testWidgets('screen type resolves medium values', (tester) async {
    ScreenType? screenType;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(700, 900)),
        child: Builder(
          builder: (context) {
            screenType = ScreenType.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(screenType, ScreenType.medium);
    expect(screenType!.screenPadding, SpacingTokens.xl);
    expect(screenType!.gridColumns, 2);
    expect(screenType!.flashcardWidth, 400);
    expect(screenType!.matchColumnWidth, 260);
  });

  testWidgets('screen type resolves expanded values', (tester) async {
    ScreenType? screenType;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(1200, 900)),
        child: Builder(
          builder: (context) {
            screenType = ScreenType.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(screenType, ScreenType.expanded);
    expect(screenType!.screenPadding, SpacingTokens.xxl);
    expect(screenType!.gridColumns, 3);
    expect(screenType!.maxContentWidth, 840);
    expect(screenType!.textScaleFactor, 1.15);
  });
}
