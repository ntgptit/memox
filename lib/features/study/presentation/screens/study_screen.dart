import 'package:flutter/material.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/study/presentation/widgets/study_placeholder_view.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({this.deckId, this.mode, super.key});

  static const String routeName = 'study';
  static const String routePath = '/study';
  static const String deckRoutePath = '/deck/:deckId/study/:mode';

  final int? deckId;
  final StudyMode? mode;

  static String routeLocation(int deckId, String mode) {
    return '/deck/$deckId/study/$mode';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(mode?.label(context.l10n) ?? context.l10n.studyTitle),
    ),
    body: const StudyPlaceholderView(),
  );
}
