import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memox/core/theme/color_schemes/app_color_scheme.dart';
import 'package:memox/core/theme/text_themes/app_text_theme.dart';
import 'package:memox/core/theme/text_themes/custom_text_styles.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';
import 'package:memox/core/theme/tokens/elevation_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

mixin AppTheme {
  static ThemeData light({Color seedColor = ColorTokens.seed}) =>
      _buildTheme(AppColorScheme.light(seedColor));

  static ThemeData dark({Color seedColor = ColorTokens.seed}) =>
      _buildTheme(AppColorScheme.dark(seedColor));

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final customColors = AppColorScheme.customColorsFor(colorScheme.brightness);
    final textTheme = AppTextTheme.build(colorScheme);
    final appTextStyles = AppTextStyles.fromTextTheme(textTheme);
    final border = BorderSide(color: colorScheme.outline);
    final inputBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        Radius.circular(RadiusTokens.input),
      ),
      borderSide: border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: <ThemeExtension<dynamic>>[customColors, appTextStyles],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: _overlayStyle(colorScheme),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: ElevationTokens.level0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.card),
          side: border,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll<double>(
            ElevationTokens.level0,
          ),
          shadowColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
          surfaceTintColor: const WidgetStatePropertyAll<Color>(
            Colors.transparent,
          ),
          minimumSize: const WidgetStatePropertyAll<Size>(
            Size(0, SizeTokens.touchTarget),
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.full),
            ),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
          ),
          textStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.labelLarge),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: customColors.surfaceDim,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.lg,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: customColors.surfaceDim,
        disabledColor: customColors.surfaceDim,
        selectedColor: customColors.mastery.withValues(
          alpha: OpacityTokens.selected,
        ),
        secondarySelectedColor: customColors.mastery.withValues(
          alpha: OpacityTokens.selected,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
        ),
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium,
        side: border,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.chip),
          side: border,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: ElevationTokens.level0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        height: SizeTokens.bottomNavHeight,
        indicatorColor: colorScheme.primary.withValues(alpha: OpacityTokens.focus),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            size: SizeTokens.iconMd,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: ElevationTokens.level0,
        highlightElevation: ElevationTokens.level0,
        focusElevation: ElevationTokens.level0,
        hoverElevation: ElevationTokens.level0,
        splashColor: colorScheme.primary.withValues(alpha: OpacityTokens.drag),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.fab),
        ),
      ),
    );
  }

  static SystemUiOverlayStyle _overlayStyle(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
        .copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: colorScheme.surface,
          systemNavigationBarDividerColor: colorScheme.outline,
        );
  }
}
