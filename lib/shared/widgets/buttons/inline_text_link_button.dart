import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/shared/widgets/buttons/app_tap_region.dart';

class InlineTextLinkButton extends StatefulWidget {
  const InlineTextLinkButton({
    required this.label,
    this.onTap,
    this.color,
    this.activeColor,
    this.textStyle,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final Color? activeColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;

  @override
  State<InlineTextLinkButton> createState() => _InlineTextLinkButtonState();
}

class _InlineTextLinkButtonState extends State<InlineTextLinkButton> {
  var _pressed = false;
  var _hovered = false;
  var _focused = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onTap != null;
    final baseColor = widget.color ?? context.colors.onSurfaceVariant;
    final accentColor = widget.activeColor ?? context.colors.primary;
    final displayColor = _hovered || _focused ? accentColor : baseColor;
    final baseStyle =
        widget.textStyle ??
        context.appTextStyles.breadcrumb.copyWith(color: baseColor);
    final resolvedStyle = baseStyle.copyWith(color: displayColor);

    if (!isInteractive) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: SizeTokens.touchTarget),
        child: Padding(
          padding: widget.padding,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(widget.label, style: resolvedStyle),
          ),
        ),
      );
    }

    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (value) => setState(() => _hovered = value),
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onTap?.call();
            return null;
          },
        ),
      },
      child: Semantics(
        button: true,
        link: true,
        child: AppTapRegion(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: SizeTokens.touchTarget,
            ),
            child: Padding(
              padding: widget.padding,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedOpacity(
                  duration: DurationTokens.fast,
                  opacity: _pressed ? OpacityTokens.hintText : 1,
                  child: Text(widget.label, style: resolvedStyle),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
