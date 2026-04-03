import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/fill/fill_engine.dart';

void main() {
  const engine = FillEngine();

  test('generatePrompt uses example and blanks the answer', () {
    final prompt = engine.generatePrompt(
      const FlashcardEntity(
        id: 1,
        deckId: 9,
        front: 'water',
        back: 'みず',
        example: 'The Japanese word for water is みず.',
      ),
    );

    expect(
      prompt.sentenceWithBlank,
      'The Japanese word for water is ________.',
    );
    expect(prompt.correctAnswer, 'みず');
    expect(prompt.hint, 'み _');
    expect(prompt.answerLength, 2);
  });

  test('generatePrompt falls back to the default sentence', () {
    final prompt = engine.generatePrompt(
      const FlashcardEntity(id: 2, deckId: 9, front: 'water', back: 'mizu'),
    );

    expect(prompt.sentenceWithBlank, "The answer for 'water' is ________");
    expect(prompt.correctAnswer, 'mizu');
  });

  test('checkAnswer maps exact, close, and wrong results', () {
    expect(engine.checkAnswer('banana', 'banana'), FillResult.correct);
    expect(engine.checkAnswer('banan', 'banana'), FillResult.close);
    expect(engine.checkAnswer('apple', 'banana'), FillResult.wrong);
  });

  test('isNumericAnswer detects numeric answers', () {
    expect(engine.isNumericAnswer('42'), isTrue);
    expect(engine.isNumericAnswer('3.14'), isTrue);
    expect(engine.isNumericAnswer('みず'), isFalse);
  });
}
