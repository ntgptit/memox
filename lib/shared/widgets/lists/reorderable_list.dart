import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class ReorderableListWidget<T extends Object> extends StatelessWidget {
  const ReorderableListWidget({
    required this.items,
    required this.onReorder,
    required this.itemBuilder,
    this.isReorderEnabled = false,
    super.key,
  });

  final List<T> items;
  final ReorderCallback onReorder;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final bool isReorderEnabled;

  @override
  Widget build(BuildContext context) {
    if (!isReorderEnabled) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return KeyedSubtree(
            key: ObjectKey(item),
            child: itemBuilder(context, item, index),
          );
        },
      );
    }

    return ReorderableListView.builder(
      padding: EdgeInsets.zero,
      buildDefaultDragHandles: false,
      itemCount: items.length,
      onReorder: (oldIndex, newIndex) =>
          onReorder(oldIndex, oldIndex < newIndex ? newIndex - 1 : newIndex),
      itemBuilder: (context, index) {
        final item = items[index];

        return Row(
          key: ObjectKey(item),
          children: [
            Listener(
              onPointerDown: (_) => HapticFeedback.selectionClick(),
              child: ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.only(right: SpacingTokens.sm),
                  child: SizedBox.square(
                    dimension: SizeTokens.avatarMd,
                    child: Icon(
                      Icons.drag_indicator_outlined,
                      size: SizeTokens.iconSm,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: itemBuilder(context, item, index)),
          ],
        );
      },
    );
  }
}
