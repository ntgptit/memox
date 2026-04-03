import 'package:flutter/material.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/study/presentation/screens/fill_mode_screen.dart';
import 'package:memox/features/study/presentation/screens/guess_mode_screen.dart';
import 'package:memox/features/study/presentation/screens/match_mode_screen.dart';
import 'package:memox/features/study/presentation/screens/recall_mode_screen.dart';
import 'package:memox/features/study/presentation/widgets/study_placeholder_view.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({this.deckId, this.mode, super.key});

  static const String routeName = 'study';
  static const String routePath = '/study';
  static const String deckRoutePath = '/deck/:deckId/study/:mode';

  final int? deckId;
  final StudyMode? mode;

  static String routeLocation(int deckId, String mode) =>
      '/deck/$deckId/study/$mode';

  @override
  Widget build(BuildContext context) {
    if (mode == StudyMode.match && deckId != null) {
      return MatchModeScreen(deckId: deckId!);
    }

    if (mode == StudyMode.guess && deckId != null) {
      return GuessModeScreen(deckId: deckId!);
    }

    if (mode == StudyMode.recall && deckId != null) {
      return RecallModeScreen(deckId: deckId!);
    }

    if (mode == StudyMode.fill && deckId != null) {
      return FillModeScreen(deckId: deckId!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(mode?.label(context.l10n) ?? context.l10n.studyTitle),
      ),
      body: const StudyPlaceholderView(),
    );
  }
}
