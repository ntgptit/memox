import 'package:flutter/material.dart';
import 'package:memox/shared/widgets/feedback/app_refresh_indicator.dart';
import 'package:memox/shared/widgets/lists/app_reorder_drag_handle.dart';

typedef ReorderableItemBuilder<T extends Object> =
    Widget Function(
      BuildContext context,
      T item,
      int index,
      Widget? reorderHandle,
    );

class ReorderableListWidget<T extends Object> extends StatelessWidget {
  const ReorderableListWidget({
    required this.items,
    required this.onReorder,
    required this.itemBuilder,
    this.onRefresh,
    this.isReorderEnabled = false,
    super.key,
  });

  final List<T> items;
  final ReorderCallback onReorder;
  final ReorderableItemBuilder<T> itemBuilder;
  final RefreshCallback? onRefresh;
  final bool isReorderEnabled;

  @override
  Widget build(BuildContext context) {
    if (!isReorderEnabled) {
      final listView = ListView.builder(
        padding: EdgeInsets.zero,
        physics: onRefresh == null
            ? null
            : const AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return KeyedSubtree(
            key: ObjectKey(item),
            child: itemBuilder(context, item, index, null),
          );
        },
      );

      if (onRefresh == null) {
        return listView;
      }

      return AppRefreshIndicator(onRefresh: onRefresh!, child: listView);
    }

    return ReorderableListView.builder(
      padding: EdgeInsets.zero,
      buildDefaultDragHandles: false,
      itemCount: items.length,
      onReorder: (oldIndex, newIndex) =>
          onReorder(oldIndex, oldIndex < newIndex ? newIndex - 1 : newIndex),
      itemBuilder: (context, index) {
        final item = items[index];

        return KeyedSubtree(
          key: ObjectKey(item),
          child: itemBuilder(
            context,
            item,
            index,
            AppReorderDragHandle(index: index),
          ),
        );
      },
    );
  }
}
