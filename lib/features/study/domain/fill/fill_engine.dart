import 'package:characters/characters.dart';
import 'package:memox/features/study/domain/srs/fuzzy_matcher.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';

const String fillBlankToken = '________';

typedef FillPrompt = ({
  String sentenceWithBlank,
  String correctAnswer,
  String? hint,
  int answerLength,
});

enum FillResult { correct, close, wrong }

final class FillEngine {
  const FillEngine({FuzzyMatcher fuzzyMatcher = const FuzzyMatcher()})
    : _fuzzyMatcher = fuzzyMatcher;

  final FuzzyMatcher _fuzzyMatcher;

  FillResult checkAnswer(String userInput, String correctAnswer) {
    final match = _fuzzyMatcher.match(userInput, correctAnswer);

    if (match == MatchResult.exact) {
      return FillResult.correct;
    }

    if (match == MatchResult.close) {
      return FillResult.close;
    }

    return FillResult.wrong;
  }

  FillPrompt generatePrompt(CardEntity card) {
    final examplePrompt = _promptFromExample(card);

    if (examplePrompt != null) {
      return examplePrompt;
    }

    final answer = card.front.trim();
    final hintPrompt = _promptFromHint(card);

    if (hintPrompt != null) {
      return _buildPrompt(sentence: hintPrompt, answer: answer);
    }

    return _buildPrompt(
      sentence: _promptFromDefinition(card.back),
      answer: answer,
    );
  }

  bool isNumericAnswer(String answer) =>
      RegExp(r'^[+-]?\d+([.,]\d+)?$').hasMatch(answer.trim());

  FillPrompt _buildPrompt({required String sentence, required String answer}) =>
      (
        sentenceWithBlank: sentence,
        correctAnswer: answer,
        hint: _hintFor(answer),
        answerLength: answer.characters.length,
      );

  String? _hintFor(String answer) {
    final characters = answer.trim().characters.toList(growable: false);

    if (characters.isEmpty) {
      return null;
    }

    if (characters.length == 1) {
      return characters.first;
    }

    return '${characters.first} ${List<String>.filled(characters.length - 1, '_').join(' ')}';
  }

  FillPrompt? _promptFromExample(CardEntity card) {
    final example = card.example.trim();

    if (example.isEmpty) {
      return null;
    }

    final frontPrompt = _blankedSentence(example, card.front.trim());

    if (frontPrompt == null) {
      return null;
    }

    return _buildPrompt(sentence: frontPrompt, answer: card.front.trim());
  }

  String _promptFromDefinition(String clue) {
    final trimmed = clue.trim();
    final shortened = trimmed.characters.take(20).toString();
    final suffix = trimmed.characters.length > 20 ? '...' : '';
    return "The word meaning '$shortened$suffix' is $fillBlankToken";
  }

  String? _promptFromHint(CardEntity card) {
    final hint = card.hint.trim();

    if (hint.isEmpty) {
      return null;
    }

    return 'Hint: $hint. The word is $fillBlankToken';
  }

  String? _blankedSentence(String sentence, String answer) {
    if (answer.isEmpty) {
      return null;
    }

    final lowerSentence = sentence.toLowerCase();
    final lowerAnswer = answer.toLowerCase();
    final startIndex = lowerSentence.indexOf(lowerAnswer);

    if (startIndex < 0) {
      return null;
    }

    return sentence.replaceRange(
      startIndex,
      startIndex + answer.length,
      fillBlankToken,
    );
  }
}
