import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/study/presentation/providers/next_due_deck_provider.dart';
import 'package:memox/features/study/presentation/screens/study_screen.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';

class StudyNextDeckButton extends ConsumerWidget {
  const StudyNextDeckButton({
    required this.currentDeckId,
    required this.mode,
    super.key,
  });

  final int currentDeckId;
  final StudyMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextDeckAsync = ref.watch(nextDueDeckProvider(currentDeckId));
    final nextDeck = nextDeckAsync.asData?.value;

    if (nextDeck == null) {
      return const SizedBox.shrink();
    }

    return SecondaryButton(
      label: context.l10n.studyNextDeckAction(nextDeck.name),
      onPressed: () => context.pushReplacement(
        StudyScreen.routeLocation(nextDeck.id, mode.name),
      ),
    );
  }
}
