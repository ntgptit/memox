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
import 'package:memox/core/theme/tokens/typography_tokens.dart';

mixin AppTheme {
  static ThemeData light({Color seedColor = ColorTokens.seed}) =>
      _buildTheme(AppColorScheme.light(seedColor));

  static ThemeData dark({Color seedColor = ColorTokens.seed}) =>
      _buildTheme(AppColorScheme.dark(seedColor));

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final customColors = AppColorScheme.customColorsFor(colorScheme.brightness);
    final textTheme = AppTextTheme.build(colorScheme);
    final appTextStyles = AppTextStyles.fromTextTheme(textTheme);
    final pageSurface = colorScheme.surface;
    final cardSurface = colorScheme.surfaceContainerLowest;
    final utilitySurface = colorScheme.surfaceContainerLowest;
    final tonalSurface = colorScheme.surfaceContainerLow;
    final emphasisSurface = colorScheme.surfaceContainerHigh;
    final border = BorderSide(
      color: colorScheme.outlineVariant.withValues(
        alpha: OpacityTokens.borderSubtle,
      ),
    );
    final transparentSurface = colorScheme.surface.withValues(alpha: 0);
    final neutralHoverColor = colorScheme.onSurface.withValues(
      alpha: OpacityTokens.hover,
    );
    final neutralPressColor = colorScheme.onSurface.withValues(
      alpha: OpacityTokens.press,
    );
    final accentHoverColor = colorScheme.primary.withValues(
      alpha: OpacityTokens.hover,
    );
    final accentFocusColor = colorScheme.primary.withValues(
      alpha: OpacityTokens.focus,
    );
    final accentPressColor = colorScheme.primary.withValues(
      alpha: OpacityTokens.press,
    );
    final onPrimaryHoverColor = colorScheme.onPrimary.withValues(
      alpha: OpacityTokens.hover,
    );
    final onPrimaryFocusColor = colorScheme.onPrimary.withValues(
      alpha: OpacityTokens.focus,
    );
    final onPrimaryPressColor = colorScheme.onPrimary.withValues(
      alpha: OpacityTokens.press,
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(RadiusTokens.input)),
      borderSide: border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: pageSurface,
      hoverColor: neutralHoverColor,
      focusColor: accentFocusColor,
      highlightColor: transparentSurface,
      splashColor: accentPressColor,
      splashFactory: InkSparkle.splashFactory,
      extensions: <ThemeExtension<dynamic>>[customColors, appTextStyles],
      appBarTheme: AppBarTheme(
        backgroundColor: transparentSurface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: transparentSurface,
        surfaceTintColor: transparentSurface,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: _overlayStyle(colorScheme),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: ElevationTokens.level1,
        margin: EdgeInsets.zero,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: transparentSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.card),
          side: border,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: utilitySurface,
        surfaceTintColor: transparentSurface,
        elevation: ElevationTokens.level1,
        shadowColor: colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.card),
          side: border,
        ),
        textStyle: textTheme.bodyMedium,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll<double>(
            ElevationTokens.level0,
          ),
          shadowColor: WidgetStatePropertyAll<Color>(transparentSurface),
          surfaceTintColor: WidgetStatePropertyAll<Color>(transparentSurface),
          minimumSize: const WidgetStatePropertyAll<Size>(
            Size(0, SizeTokens.touchTarget),
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.button),
            ),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(
              horizontal: SpacingTokens.xl,
              vertical: SpacingTokens.md,
            ),
          ),
          textStyle: WidgetStatePropertyAll<TextStyle?>(
            textTheme.titleSmall?.copyWith(fontWeight: TypographyTokens.bold),
          ),
          overlayColor: _stateLayer(
            hovered: onPrimaryHoverColor,
            focused: onPrimaryFocusColor,
            pressed: onPrimaryPressColor,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(
            Size(0, SizeTokens.touchTarget),
          ),
          backgroundColor: WidgetStatePropertyAll<Color>(emphasisSurface),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.button),
            ),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(
              horizontal: SpacingTokens.xl,
              vertical: SpacingTokens.md,
            ),
          ),
          side: WidgetStatePropertyAll<BorderSide>(
            border.copyWith(
              color: colorScheme.outlineVariant.withValues(alpha: 0),
            ),
          ),
          textStyle: WidgetStatePropertyAll<TextStyle?>(
            textTheme.titleSmall?.copyWith(fontWeight: TypographyTokens.bold),
          ),
          overlayColor: _stateLayer(
            hovered: accentHoverColor,
            focused: accentFocusColor,
            pressed: accentPressColor,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(
            Size(0, SizeTokens.touchTarget),
          ),
          foregroundColor: WidgetStatePropertyAll<Color>(
            colorScheme.onSurfaceVariant,
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.button),
            ),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: SpacingTokens.md),
          ),
          textStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.labelLarge),
          overlayColor: _stateLayer(
            hovered: neutralHoverColor,
            focused: accentFocusColor,
            pressed: neutralPressColor,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll<double>(
            ElevationTokens.level0,
          ),
          shadowColor: WidgetStatePropertyAll<Color>(transparentSurface),
          surfaceTintColor: WidgetStatePropertyAll<Color>(transparentSurface),
          minimumSize: const WidgetStatePropertyAll<Size>(
            Size(0, SizeTokens.touchTarget),
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.button),
            ),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(
              horizontal: SpacingTokens.xl,
              vertical: SpacingTokens.md,
            ),
          ),
          textStyle: WidgetStatePropertyAll<TextStyle?>(
            textTheme.titleSmall?.copyWith(fontWeight: TypographyTokens.bold),
          ),
          overlayColor: _stateLayer(
            hovered: onPrimaryHoverColor,
            focused: onPrimaryFocusColor,
            pressed: onPrimaryPressColor,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(
            Size(SizeTokens.touchTarget, SizeTokens.touchTarget),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.zero,
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.input),
            ),
          ),
          backgroundColor: _stateLayer(
            hovered: neutralHoverColor,
            focused: accentFocusColor,
            pressed: neutralPressColor,
          ),
          overlayColor: _stateLayer(
            hovered: transparentSurface,
            focused: transparentSurface,
            pressed: neutralPressColor,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tonalSurface,
        hoverColor: neutralHoverColor,
        focusColor: accentFocusColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.md,
        ),
        hintStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(
            alpha: OpacityTokens.hintText,
          ),
        ),
        labelStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.primary,
        ),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
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
      dialogTheme: DialogThemeData(
        backgroundColor: utilitySurface,
        surfaceTintColor: transparentSurface,
        shadowColor: colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.dialog),
          side: border,
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: utilitySurface,
        surfaceTintColor: transparentSurface,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(RadiusTokens.sheet),
          ),
          side: border,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardSurface,
        disabledColor: cardSurface,
        selectedColor: colorScheme.primary.withValues(
          alpha: OpacityTokens.focus,
        ),
        secondarySelectedColor: colorScheme.primary.withValues(
          alpha: OpacityTokens.focus,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: SpacingTokens.xs,
        ),
        labelStyle: textTheme.labelSmall,
        secondaryLabelStyle: textTheme.labelSmall,
        side: border,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.full),
          side: border,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(
            Size(0, SizeTokens.buttonHeightSm),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: SpacingTokens.md),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary.withValues(alpha: OpacityTokens.focus);
            }

            return cardSurface;
          }),
          side: WidgetStatePropertyAll<BorderSide>(border),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.full),
            ),
          ),
          textStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.labelLarge),
          overlayColor: _stateLayer(
            hovered: accentHoverColor,
            focused: accentFocusColor,
            pressed: accentPressColor,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: transparentSurface,
        elevation: ElevationTokens.level0,
        shadowColor: transparentSurface,
        surfaceTintColor: transparentSurface,
        height: SizeTokens.bottomNavHeight,
        indicatorColor: colorScheme.primary.withValues(
          alpha: OpacityTokens.hover,
        ),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
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
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: ElevationTokens.level2,
        highlightElevation: ElevationTokens.level2,
        focusElevation: ElevationTokens.level2,
        hoverElevation: ElevationTokens.level2,
        splashColor: colorScheme.primary.withValues(alpha: OpacityTokens.drag),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.fab),
        ),
      ),
    );
  }

  static WidgetStateProperty<Color?> _stateLayer({
    required Color hovered,
    required Color focused,
    required Color pressed,
  }) => WidgetStateProperty.resolveWith<Color?>((states) {
    if (states.contains(WidgetState.disabled)) {
      return null;
    }

    if (states.contains(WidgetState.pressed)) {
      return pressed;
    }

    if (states.contains(WidgetState.focused)) {
      return focused;
    }

    if (states.contains(WidgetState.hovered)) {
      return hovered;
    }

    return null;
  });

  static SystemUiOverlayStyle _overlayStyle(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
        .copyWith(
          statusBarColor: colorScheme.surface.withValues(alpha: 0),
          systemNavigationBarColor: colorScheme.surface,
          systemNavigationBarDividerColor: colorScheme.outline,
        );
  }
}
