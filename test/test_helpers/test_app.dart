import 'package:flutter/material.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

MaterialApp buildTestApp({required Widget home, ThemeData? theme}) =>
    MaterialApp(
      theme: theme ?? AppTheme.light(),
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      home: home,
    );
