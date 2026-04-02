import 'package:flutter/material.dart';
import 'package:memox/core/theme/color_schemes/custom_colors.dart';
import 'package:memox/core/theme/text_themes/custom_text_styles.dart';

extension ThemeDataX on ThemeData {
  CustomColors get customColors => extension<CustomColors>()!;

  AppTextStyles get appTextStyles => extension<AppTextStyles>()!;
}
