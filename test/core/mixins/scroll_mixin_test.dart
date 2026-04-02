import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/mixins/scroll_mixin.dart';

void main() {
  testWidgets('scroll mixin detects bottom and triggers onScrollEnd', (
    tester,
  ) async {
    var called = 0;
    final key = GlobalKey<_ScrollHarnessState>();

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 200,
          child: _ScrollHarness(
            key: key,
            onScrollEnd: () => called++,
          ),
        ),
      ),
    );

    final state = key.currentState!;

    expect(state.scrollController.hasClients, isTrue);
    expect(state.isAtBottom, isFalse);

    state.scrollController.jumpTo(
      state.scrollController.position.maxScrollExtent,
    );
    await tester.pump();

    expect(state.isAtBottom, isTrue);
    expect(called, 1);
  });

  testWidgets('scrollToTop supports jump and animated modes', (tester) async {
    final key = GlobalKey<_ScrollHarnessState>();

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 200,
          child: _ScrollHarness(
            key: key,
            onScrollEnd: () {},
          ),
        ),
      ),
    );

    final state = key.currentState!;

    state.scrollController.jumpTo(
      state.scrollController.position.maxScrollExtent,
    );
    await tester.pump();
    expect(state.scrollController.offset, greaterThan(0));

    state.scrollToTop(animated: false);
    await tester.pump();
    expect(state.scrollController.offset, 0);

    state.scrollController.jumpTo(
      state.scrollController.position.maxScrollExtent,
    );
    await tester.pump();

    state.scrollToTop();
    await tester.pumpAndSettle();
    expect(state.scrollController.offset, 0);
    expect(state.isAtBottom, isFalse);
  });
}

class _ScrollHarness extends StatefulWidget {
  const _ScrollHarness({
    required this.onScrollEnd,
    super.key,
  });

  final VoidCallback onScrollEnd;

  @override
  State<_ScrollHarness> createState() => _ScrollHarnessState();
}

class _ScrollHarnessState extends State<_ScrollHarness>
    with ScrollMixin<_ScrollHarness> {
  @override
  void onScrollEnd() => widget.onScrollEnd();

  @override
  Widget build(BuildContext context) => ListView.builder(
    controller: scrollController,
    itemCount: 40,
    itemBuilder: (context, index) => const SizedBox(height: 60),
  );
}
