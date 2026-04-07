import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/shared/widgets/buttons/icon_action_button.dart';

import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('IconActionButton uses shared neutral surface styling', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: Center(
            child: IconActionButton(icon: Icons.add_outlined, onTap: () {}),
          ),
        ),
      ),
    );

    final context = tester.element(find.byType(IconButton));
    final button = tester.widget<IconButton>(find.byType(IconButton));
    final style = button.style;

    expect(style?.minimumSize?.resolve({}), const Size.square(48));
    expect(
      style?.backgroundColor?.resolve({}),
      Theme.of(context).colorScheme.surfaceContainerHigh,
    );
    expect(
      style?.foregroundColor?.resolve({}),
      Theme.of(context).colorScheme.onSurface,
    );
    expect(
      style?.side?.resolve({})?.color,
      Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: OpacityTokens.focus),
    );
  });

  testWidgets('IconActionButton softens surface styling when disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const Scaffold(
          body: Center(child: IconActionButton(icon: Icons.add_outlined)),
        ),
      ),
    );

    final context = tester.element(find.byType(IconButton));
    final button = tester.widget<IconButton>(find.byType(IconButton));
    final style = button.style;
    const disabledState = <WidgetState>{WidgetState.disabled};

    expect(
      style?.backgroundColor?.resolve(disabledState),
      Theme.of(context).colorScheme.surfaceContainer,
    );
    expect(
      style?.side?.resolve(disabledState)?.color,
      Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: OpacityTokens.borderSubtle),
    );
  });
}
