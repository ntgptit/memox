import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/features/study/presentation/providers/study_provider.dart';
import 'package:memox/features/study/presentation/widgets/study_placeholder_view.dart';

class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  static const String routeName = 'study';
  static const String routePath = '/study';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(studyScreenTitleProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const StudyPlaceholderView(),
    );
  }
}
