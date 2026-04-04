import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

class AppReorderDragHandle extends StatelessWidget {
  const AppReorderDragHandle({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => HapticFeedback.selectionClick(),
    child: ReorderableDragStartListener(
      index: index,
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Semantics(
          button: true,
          label: context.l10n.reorderAction,
          child: SizedBox.square(
            dimension: SizeTokens.touchTarget,
            child: Icon(
              Icons.drag_indicator_outlined,
              size: SizeTokens.iconSm,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    ),
  );
}
