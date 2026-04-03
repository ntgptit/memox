import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/study/domain/srs/fuzzy_matcher.dart';

void main() {
  const matcher = FuzzyMatcher();

  test('returns exact for normalized matches', () {
    expect(matcher.match('  Xin   Chao  ', 'xin chao'), MatchResult.exact);
  });

  test('returns close for small typos', () {
    expect(matcher.match('helo', 'hello'), MatchResult.close);
    expect(matcher.levenshteinDistance('helo', 'hello'), 1);
  });

  test('returns close when the only difference is accents', () {
    expect(matcher.match('xin chao', 'xin chào'), MatchResult.close);
  });

  test('returns wrong for completely different answers', () {
    expect(matcher.match('dog', 'cat'), MatchResult.wrong);
  });

  test('handles Japanese Unicode text correctly', () {
    expect(matcher.match('こんにちは', '  こんにちは  '), MatchResult.exact);
    expect(matcher.match('ありがと', 'ありがとう'), MatchResult.close);
    expect(matcher.match('おはよう', 'こんばんは'), MatchResult.wrong);
  });
}
