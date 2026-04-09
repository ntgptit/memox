import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/shared/widgets/buttons/primary_button.dart';
import 'package:memox/shared/widgets/navigation/top_bar_back_button.dart';

class EditorTopBar extends StatelessWidget implements PreferredSizeWidget {
  const EditorTopBar({
    required this.title,
    required this.onClose,
    this.onSave,
    super.key,
  });
  final String title;
  final VoidCallback onClose;
  final VoidCallback? onSave;
  @override
  Size get preferredSize => const Size.fromHeight(SizeTokens.appBarHeightLg);
  @override
  Widget build(BuildContext context) => Material(
    color: context.colors.surface.withValues(alpha: 1 - OpacityTokens.hover),
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colors.outlineVariant.withValues(
              alpha: OpacityTokens.borderSubtle,
            ),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: SizeTokens.appBarHeightLg,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.screenType.screenPadding,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: TopBarBackButton.balancedSlotWidth,
                  child: TopBarBackButton(onPressed: onClose),
                ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium,
                  ),
                ),
                SizedBox(
                  width: TopBarBackButton.balancedSlotWidth,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: onSave == null
                        ? const SizedBox.shrink()
                        : PrimaryButton(
                            label: context.l10n.saveAction,
                            onPressed: onSave,
                            fullWidth: false,
                            height: SizeTokens.buttonHeightSm,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
