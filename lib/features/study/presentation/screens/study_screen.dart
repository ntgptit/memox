import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/study/presentation/widgets/study_placeholder_view.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  static const String routeName = 'study';
  static const String routePath = '/study';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.studyTitle)),
    body: const StudyPlaceholderView(),
  );
}
