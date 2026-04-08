import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

typedef StudyMistakeItem = ({String front, String back});

class StudyMistakesPanel extends StatefulWidget {
  const StudyMistakesPanel({required this.items, super.key});

  final List<StudyMistakeItem> items;

  @override
  State<StudyMistakesPanel> createState() => _StudyMistakesPanelState();
}

class _StudyMistakesPanelState extends State<StudyMistakesPanel> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextLinkButton(
            label: context.l10n.studyMistakesListAction,
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded) ...[
            const SizedBox(height: SpacingTokens.md),
            for (final item in widget.items)
              Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                child: Text(
                  '${item.front} → ${item.back}',
                  style: context.textTheme.bodySmall,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
