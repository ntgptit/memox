import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/match/match_engine.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/presentation/providers/match_provider.dart';
import 'package:memox/features/study/presentation/screens/match_mode_screen.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import '../../../../test_helpers/fakes/fake_card_review_dao.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('MatchModeScreen renders the current round', (tester) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 4,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
              ],
            ),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          matchEngineProvider(
            4,
          ).overrideWithValue(MatchEngine(random: Random(1))),
        ],
        child: buildTestApp(home: const MatchModeScreen(deckId: 4)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Match'), findsOneWidget);
    expect(find.text('1 pair left'), findsOneWidget);
    expect(find.text('안녕하세요'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);

    final termText = tester.widget<Text>(find.text('안녕하세요'));
    final definitionText = tester.widget<Text>(find.text('Hello'));
    expect(termText.style?.fontSize, TypographyTokens.headlineMedium);
    expect(definitionText.style?.fontSize, TypographyTokens.titleMedium);

    final termCard = find
        .ancestor(of: find.text('안녕하세요'), matching: find.byType(AppCard))
        .first;
    final definitionCard = find
        .ancestor(of: find.text('Hello'), matching: find.byType(AppCard))
        .first;
    final termRect = tester.getRect(termCard);
    final definitionRect = tester.getRect(definitionCard);

    expect(termRect.width, closeTo(definitionRect.width, 1));
    expect(termRect.height, closeTo(definitionRect.height, 1));
  });

  testWidgets('MatchModeScreen shows completion after a correct match', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 4,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
              ],
            ),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          matchEngineProvider(
            4,
          ).overrideWithValue(MatchEngine(random: Random(1))),
        ],
        child: buildTestApp(home: const MatchModeScreen(deckId: 4)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('안녕하세요'));
    await tester.tap(find.text('Hello'));
    await tester.pumpAndSettle();

    expect(find.text('All matched!'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('MatchModeScreen truncates long definitions with ellipsis', (
    tester,
  ) async {
    const longDefinition =
        'Drowsy driving / Lái xe khi buồn ngủ '
        '(Danh từ, hành vi lái xe trong trạng thái buồn ngủ gây nguy hiểm)';
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 4,
                  front: '졸음운전',
                  back: longDefinition,
                ),
              ],
            ),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          matchEngineProvider(
            4,
          ).overrideWithValue(MatchEngine(random: Random(1))),
        ],
        child: buildTestApp(home: const MatchModeScreen(deckId: 4)),
      ),
    );
    await tester.pumpAndSettle();

    final definitionText = tester.widget<Text>(find.text(longDefinition));

    expect(definitionText.maxLines, 4);
    expect(definitionText.overflow, TextOverflow.ellipsis);
  });
}

final class _FakeStudyRepository implements StudyRepository {
  @override
  Future<StudySession> completeSession(StudySession session) async => session;

  @override
  Future<StudySession> startSession({
    required int deckId,
    StudyMode mode = StudyMode.review,
  }) async => StudySession(
    id: 1,
    deckId: deckId,
    mode: mode,
    startedAt: DateTime(2026, 4, 3, 10),
  );

  @override
  Stream<List<StudySession>> watchAll() async* {
    yield const <StudySession>[];
  }
}
