import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/core/responsive/screen_type.dart';
import 'package:memox/core/theme/color_schemes/custom_colors.dart';
import 'package:memox/core/theme/text_themes/custom_text_styles.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/shared/widgets/dialogs/confirm_dialog.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  CustomColors get customColors => theme.extension<CustomColors>()!;

  AppTextStyles get appTextStyles => theme.extension<AppTextStyles>()!;

  L10n get l10n => L10n.of(this);

  bool get isDark => theme.brightness == Brightness.dark;

  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  bool get isKeyboardVisible => viewInsets.bottom > 0;

  ScreenType get screenType => ScreenType.of(this);

  bool get isCompact => screenType == ScreenType.compact;

  bool get isMedium => screenType == ScreenType.medium;

  bool get isExpanded => screenType == ScreenType.expanded;

  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? customColors.ratingAgain : null,
      ),
    );
  }

  Future<T?> showAppBottomSheet<T>(Widget child) => showModalBottomSheet<T>(
    context: this,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => child,
  );

  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = AppStrings.confirmAction,
    bool isDestructive = false,
  }) => showDialog<bool>(
    context: this,
    builder: (_) => ConfirmDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      isDestructive: isDestructive,
    ),
  );

  CustomColors get appColors => customColors;
}
