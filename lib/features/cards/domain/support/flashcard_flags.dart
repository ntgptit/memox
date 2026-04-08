import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';

const String flaggedCardTag = '__memox_flagged__';

bool isInternalCardTag(String tag) => tag == flaggedCardTag;

List<String> mergeInternalCardTags({
  required List<String> originalTags,
  required List<String> visibleTags,
}) {
  final internalTags = originalTags
      .where(isInternalCardTag)
      .toList(growable: false);
  final nextVisibleTags = visibleTags
      .where((tag) => !isInternalCardTag(tag))
      .toList(growable: true);
  return <String>[...nextVisibleTags, ...internalTags];
}

extension FlashcardFlagX on FlashcardEntity {
  bool get isFlagged => tags.contains(flaggedCardTag);

  List<String> get visibleTags =>
      tags.where((tag) => !isInternalCardTag(tag)).toList(growable: false);

  FlashcardEntity copyWithFlagged({required bool isFlagged}) {
    final nextTags = visibleTags.toList(growable: true);

    if (isFlagged) {
      nextTags.add(flaggedCardTag);
    }

    return copyWith(tags: nextTags);
  }
}
