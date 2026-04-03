/// Fixed component sizes — NOT spacing between things.
/// Spacing = distance between elements (SpacingTokens).
/// Size = dimensions OF an element (SizeTokens).
abstract final class SizeTokens {
  // ── Touch Targets (M3 minimum) ──
  static const double touchTarget = 48;

  // ── Icons ──
  static const double iconXs = 16; // inline indicators, status dots
  static const double iconSm = 20; // button icons, chip icons
  static const double iconMd = 24; // standard M3 icon size
  static const double iconLg = 32; // empty state secondary
  static const double iconXl = 64; // empty state primary

  // ── Avatars ──
  static const double avatarSm = 24; // inline mentions
  static const double avatarMd = 32; // app bar, list leading
  static const double avatarLg = 40; // profile, folder icon container
  static const double avatarXl = 64; // profile screen

  // ── Buttons ──
  static const double buttonHeight = 48; // standard M3
  static const double buttonHeightSm =
      36; // compact (e.g. "Check" in fill mode input)
  static const double buttonHeightLg = 52; // primary CTA ("Study X due cards")
  static const double fabSize = 56; // standard FAB
  static const double fabSizeSmall = 40; // small FAB

  // ── Inputs ──
  static const double inputHeight = 52; // outlined text field
  static const double searchBarHeight = 48;
  static const double deckDetailHeaderHeightCompact = 208;
  static const double deckDetailHeaderHeight = 224;

  // ── Dialogs ──
  static const double dialogWidthMd = 420;
  static const double dialogWidthLg = 480;

  // ── List Items ──
  static const double listItemHeight = 56; // standard row (folder, deck, card)
  static const double listItemCompact =
      52; // compact row (study mode options, settings)
  static const double listItemTall = 72; // two-line with thumbnail

  // ── Chips ──
  static const double chipHeight = 32; // M3 standard
  static const double chipHeightSm = 24; // inline tags, category labels

  // ── Navigation ──
  static const double appBarHeight = 56; // standard
  static const double appBarHeightLg = 64; // large/medium top app bar collapsed
  static const double bottomNavHeight = 80; // M3 NavigationBar
  static const double bottomSheetHandle = 4; // drag handle height
  static const double bottomSheetHandleWidth = 32;

  // ── Progress ──
  static const double progressBarHeight = 3; // study mode top bar
  static const double masteryBarHeight = 4; // deck mastery bar
  static const double masteryRingSize = 40; // circular progress in list tiles
  static const double masteryRingStroke = 3;

  // ── Cards (study modes) ──
  static const double flashcardMinHeight = 300;
  static const double flashcardMaxHeight = 400;
  static const double ratingButtonWidth = 72;
  static const double ratingButtonHeight = 48;
  static const double maxBodyWidth = 720;
  static const double emptyStateTextWidth = 280;

  // ── Status Dot ──
  static const double statusDotSize = 8; // card status indicator
  static const double statusDotSizeLg = 12; // legend dots in charts

  // ── Dividers ──
  static const double dividerThickness = 1;
  static const double borderWidth = 1;
  static const double borderWidthThick =
      3; // left accent border on comparison cards
}
