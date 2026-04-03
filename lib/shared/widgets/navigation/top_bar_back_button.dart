import 'package:flutter/material.dart';
import 'package:memox/shared/widgets/navigation/top_bar_icon_button.dart';

class TopBarBackButton extends StatelessWidget {
  const TopBarBackButton({
    required this.onPressed,
    this.startPadding = 0,
    super.key,
  });

  static const double balancedSlotWidth = TopBarIconButton.balancedSlotWidth;

  final VoidCallback onPressed;
  final double startPadding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: startPadding),
    child: TopBarIconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: onPressed,
      icon: Icons.arrow_back_outlined,
      alignment: Alignment.centerLeft,
    ),
  );
}
