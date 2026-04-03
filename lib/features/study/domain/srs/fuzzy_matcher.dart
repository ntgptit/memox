import 'dart:math' as math;

enum MatchResult { exact, close, wrong }

final class FuzzyMatcher {
  const FuzzyMatcher();

  static const Map<String, String> _accentGroups = <String, String>{
    'a': 'áàảãạăắằẳẵặâấầẩẫậäåāą',
    'c': 'çćč',
    'd': 'đď',
    'e': 'éèẻẽẹêếềểễệëēę',
    'i': 'íìỉĩịïīį',
    'n': 'ñńň',
    'o': 'óòỏõọôốồổỗộơớờởỡợöøōő',
    's': 'śšș',
    'u': 'úùủũụưứừửữựüūůű',
    'y': 'ýỳỷỹỵÿ',
    'z': 'źžż',
  };

  MatchResult match(String userAnswer, String correctAnswer) {
    final normalizedUserAnswer = _normalize(userAnswer);
    final normalizedCorrectAnswer = _normalize(correctAnswer);

    if (normalizedUserAnswer == normalizedCorrectAnswer) {
      return MatchResult.exact;
    }

    final accentInsensitiveUserAnswer = _stripAccents(normalizedUserAnswer);
    final accentInsensitiveCorrectAnswer = _stripAccents(
      normalizedCorrectAnswer,
    );

    if (accentInsensitiveUserAnswer == accentInsensitiveCorrectAnswer) {
      return MatchResult.close;
    }

    if (levenshteinDistance(normalizedUserAnswer, normalizedCorrectAnswer) <=
        2) {
      return MatchResult.close;
    }

    return MatchResult.wrong;
  }

  int levenshteinDistance(String left, String right) {
    final leftRunes = left.runes.toList(growable: false);
    final rightRunes = right.runes.toList(growable: false);

    if (leftRunes.isEmpty) {
      return rightRunes.length;
    }

    if (rightRunes.isEmpty) {
      return leftRunes.length;
    }

    var previousRow = List<int>.generate(
      rightRunes.length + 1,
      (index) => index,
      growable: false,
    );
    final currentRow = List<int>.filled(rightRunes.length + 1, 0);

    for (var leftIndex = 0; leftIndex < leftRunes.length; leftIndex++) {
      currentRow[0] = leftIndex + 1;

      for (var rightIndex = 0; rightIndex < rightRunes.length; rightIndex++) {
        final substitutionCost = leftRunes[leftIndex] == rightRunes[rightIndex]
            ? 0
            : 1;
        currentRow[rightIndex + 1] = math.min(
          math.min(currentRow[rightIndex] + 1, previousRow[rightIndex + 1] + 1),
          previousRow[rightIndex] + substitutionCost,
        );
      }

      previousRow = List<int>.from(currentRow, growable: false);
    }

    return previousRow.last;
  }

  String _normalize(String value) {
    final trimmed = value.trim().toLowerCase();
    return trimmed.replaceAll(RegExp(r'\s+'), ' ');
  }

  String _stripAccents(String value) {
    var normalized = value;

    for (final entry in _accentGroups.entries) {
      normalized = normalized.replaceAll(RegExp('[${entry.value}]'), entry.key);
    }

    return normalized;
  }
}
