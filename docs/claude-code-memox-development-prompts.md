# 🛠️ Bộ Prompt phát triển App MemoX — Claude Code / Codex

> **Mục đích**: Bộ prompt từng bước để Claude Code hoặc OpenAI Codex
> xây dựng hoàn chỉnh app Flutter từ kiến trúc đến deploy.
>
> **Cách dùng**: Chạy từng prompt theo thứ tự trong Claude Code CLI
> hoặc Codex agent. Mỗi prompt tạo ra một phần hoàn chỉnh, test được.

---

## 📋 Quy ước chung

Dán block sau vào **system prompt** hoặc **CLAUDE.md** của project:

```
PROJECT: MemoX — Personal Flashcard Learning App
STACK: Flutter 3.24+ / Dart 3.5+
STATE MANAGEMENT: Riverpod (riverpod, flutter_riverpod, riverpod_annotation, riverpod_generator)
NAVIGATION: GoRouter (go_router)
LOCAL DB: Isar Database (isar, isar_flutter_libs, isar_generator)
ANIMATIONS: flutter_animate
THEME: Material 3 (useMaterial3: true)
FONT: Google Fonts — "Plus Jakarta Sans"
ARCHITECTURE: Feature-first Clean Architecture
  lib/
    core/          → theme, constants, utils, extensions, router
    shared/        → reusable widgets, shared providers
    features/
      folders/     → data / domain / presentation
      decks/       → data / domain / presentation
      cards/       → data / domain / presentation
      study/       → data / domain / presentation (all 5 modes)
      statistics/  → data / domain / presentation
      settings/    → data / domain / presentation

CODING RULES:
- Dart 3.5 records & patterns khi phù hợp
- Riverpod generators (@riverpod annotation) — không dùng StateNotifier cũ
- Tất cả model classes dùng freezed + json_serializable
- Isar collection cho persistence, migration-safe
- Mọi widget tách thành small composable widgets (max 80 dòng/widget)
- Const constructors mọi nơi có thể
- KHÔNG hardcode strings — dùng context.l10n.*
- KHÔNG hardcode colors — dùng context.colors.* / context.customColors.*
- KHÔNG hardcode dimensions — dùng SpacingTokens, SizeTokens, RadiusTokens
- KHÔNG hardcode text styles — dùng context.textTheme.* / context.appTextStyles.*
- KHÔNG hardcode durations — dùng DurationTokens.*
- KHÔNG dùng else — early return, switch expression, hoặc reassign
- AsyncValue phải dùng AppAsyncBuilder — KHÔNG raw .when()
- Session complete phải dùng SessionCompleteView — KHÔNG tự build
- Study top bar phải dùng StudyTopBar — KHÔNG tự build
- Swipe-to-delete phải dùng AppSlidableRow — KHÔNG raw Dismissible
- Cards phải dùng AppCard — KHÔNG raw Card()
- Buttons phải dùng PrimaryButton/SecondaryButton
- Test: unit test cho domain logic, widget test cho UI critical

REFERENCE DOCS (đọc TRƯỚC khi code):
- memox-folder-structure-and-codebase-foundation.md → tokens, widgets, specs
- memox-codebase-supplement-advanced.md → DI, SOLID, patterns, l10n
```

---

## PHASE 1: PROJECT FOUNDATION

### PROMPT 1.1 — Khởi tạo project & dependencies

```
Khởi tạo Flutter project "memox" với cấu trúc Clean Architecture.

1. Tạo project:
   flutter create memox --org com.memox --platforms android,ios

2. Thiết lập pubspec.yaml với dependencies:
   Core:
   - flutter_riverpod, riverpod_annotation, riverpod_generator
   - go_router
   - freezed_annotation, json_annotation
   - google_fonts
   - flutter_animate
   
   Database:
   - isar, isar_flutter_libs
   
   Dev:
   - build_runner, freezed, json_serializable
   - riverpod_generator, riverpod_lint
   - isar_generator
   - flutter_test, mocktail

3. Tạo cấu trúc thư mục đầy đủ:
   lib/
     core/
       theme/         → app_theme.dart, color_schemes.dart, text_styles.dart, dimensions.dart
       router/        → app_router.dart
       constants/     → app_strings.dart, app_durations.dart
       utils/         → date_utils.dart, string_utils.dart
       extensions/    → context_extensions.dart, datetime_extensions.dart
     features/
       folders/
         data/        → models/, repositories/
         domain/      → entities/, usecases/
         presentation/→ screens/, widgets/, providers/
       decks/         → (same structure)
       cards/         → (same structure)
       study/         → (same structure)
       statistics/    → (same structure)
       settings/      → (same structure)
     app.dart         → MaterialApp.router wrapper

4. Tạo file .gitignore chuẩn Flutter, analysis_options.yaml 
   với riverpod_lint rules enabled.

5. Chạy flutter pub get và đảm bảo project build thành công.

Chỉ tạo cấu trúc và placeholder files. Chưa implement logic.
```

---

### PROMPT 1.2 — Theme System (Material 3)

```
Implement Material 3 theme system cho MemoX.

FILE: lib/core/theme/color_schemes.dart
- Tạo ColorScheme.fromSeed với seedColor: Color(0xFF5C6BC0) (muted indigo)
- Light scheme: surface #FAFAFA, onSurface #1D1D1F (never pure black)
- Dark scheme: surface #1C1C1E, tương ứng
- Định nghĩa custom colors qua ThemeExtension<AppColors>:
  + success: Color(0xFF4DB6AC) — soft teal
  + warning: Color(0xFFFFB74D) — soft amber  
  + error: Color(0xFFE57373) — muted coral
  + mastery: Color(0xFF66BB6A) — soft green
  + surfaceDim: Color(0xFFF5F5F5) / Color(0xFF2C2C2E)

FILE: lib/core/theme/text_styles.dart
- Tạo TextTheme sử dụng GoogleFonts.plusJakartaSansTextTheme()
- Headings: fontWeight 600, letterSpacing -0.02
- Body: fontWeight 400, height 1.5
- Caption: 12sp, secondary color

FILE: lib/core/theme/dimensions.dart
- Class AppDimensions (tất cả static const):
  + radiusSmall: 8, radiusMedium: 12, radiusLarge: 16, radiusFull: 24
  + paddingSmall: 8, paddingMedium: 16, paddingLarge: 24
  + iconSize: 24, avatarSize: 32, fabSize: 56
  + cardElevation: 0 (dùng border thay vì shadow)
  + borderWidth: 1, borderOpacity: 0.08
  + touchTarget: 48 (minimum touch target M3)
  + progressBarHeight: 3

FILE: lib/core/theme/app_theme.dart
- Hàm AppTheme.light() và AppTheme.dark() trả về ThemeData
- useMaterial3: true
- Cấu hình component themes:
  + CardTheme: shape RoundedRectangle 16dp, elevation 0, 
    side BorderSide(color: outline, width: 1)
  + ElevatedButtonTheme: shape 24dp radius, height 48dp
  + InputDecorationTheme: outlined border, 12dp radius
  + ChipThemeData: 8dp radius, outlined
  + NavigationBarThemeData: no shadow, subtle top border
  + FloatingActionButtonThemeData: 16dp radius
  + AppBarTheme: transparent, no shadow, systemUiOverlayStyle

FILE: lib/core/constants/app_durations.dart
- Tất cả animation durations:
  + fast: 150ms, normal: 200ms, slow: 300ms
  + flip: 350ms, fadeIn: 200ms, stagger: 50ms

Đảm bảo hot reload giữ state, theme switch smooth.
Tạo một test screen đơn giản hiển thị tất cả components để verify theme.
```

---

### PROMPT 1.3 — Data Layer (Isar Database + Models)

```
Implement data layer cho MemoX sử dụng Isar database.

=== ENTITY MODELS (dùng freezed + Isar collection) ===

FILE: lib/features/folders/data/models/folder_model.dart
@Collection()
class FolderModel:
  - Id id (Isar auto-increment)
  - String name
  - String? parentId (null = root folder)
  - int colorValue (stored as int, convert to Color)
  - DateTime createdAt
  - DateTime updatedAt
  - int sortOrder
  
  // Isar links (không dùng, quản lý bằng parentId để linh hoạt hơn)
  // Index trên parentId để query nhanh

FILE: lib/features/decks/data/models/deck_model.dart
@Collection()  
class DeckModel:
  - Id id
  - String name
  - String? description
  - String folderId (folder chứa deck này)
  - int colorValue
  - List<String> tags
  - DateTime createdAt
  - DateTime updatedAt
  - int sortOrder

FILE: lib/features/cards/data/models/card_model.dart
@Collection()
class CardModel:
  - Id id
  - String deckId
  - String front (term/question)
  - String back (definition/answer)
  - String? hint
  - String? example
  - String? imagePath
  - CardStatus status (enum: newCard, learning, reviewing, mastered)
  - DateTime createdAt
  - DateTime updatedAt
  
  // SRS fields:
  - double easeFactor (default 2.5, SM-2 algorithm)
  - int interval (days until next review)
  - int repetitions (consecutive correct answers)
  - DateTime? nextReviewDate
  - DateTime? lastReviewedAt

FILE: lib/features/study/data/models/study_session_model.dart
@Collection()
class StudySessionModel:
  - Id id
  - String deckId
  - StudyMode mode (enum: review, match, guess, recall, fill)
  - DateTime startedAt
  - DateTime? completedAt
  - int totalCards
  - int correctCount
  - int wrongCount
  - int durationSeconds
  - double accuracy (computed)

FILE: lib/features/study/data/models/card_review_model.dart
@Collection()
class CardReviewModel:
  - Id id
  - String cardId
  - String sessionId
  - StudyMode mode
  - ReviewRating rating (enum: again, hard, good, easy — for review mode)
  - SelfRating? selfRating (enum: missed, partial, gotIt — for recall mode)
  - bool isCorrect
  - String? userAnswer (cho fill/recall mode)
  - int responseTimeMs
  - DateTime reviewedAt

=== ENUMS ===
- CardStatus { newCard, learning, reviewing, mastered }
- StudyMode { review, match, guess, recall, fill }  
- ReviewRating { again, hard, good, easy }
- SelfRating { missed, partial, gotIt }

=== REPOSITORIES ===
Tạo abstract repository interfaces trong domain/ 
và implementations trong data/repositories/:

FolderRepository:
- getAll() → Stream<List<Folder>>
- getRootFolders() → Stream<List<Folder>>
- getSubfolders(parentId) → Stream<List<Folder>>
- getById(id) → Future<Folder?>
- create(folder) → Future<Folder>
- update(folder) → Future<void>
- delete(id) → Future<void> (cascade delete subfolders + decks + cards)
- hasSubfolders(id) → Future<bool>
- hasDecks(id) → Future<bool>
- reorder(id, newSortOrder) → Future<void>

DeckRepository:
- getByFolder(folderId) → Stream<List<Deck>>
- getById(id) → Future<Deck?>
- create(deck) → Future<Deck>
- update(deck) → Future<void>
- delete(id) → Future<void> (cascade delete cards + reviews)
- getCardCount(deckId) → Future<int>
- getDueCardCount(deckId) → Future<int>
- getMasteryPercentage(deckId) → Future<double>

CardRepository:
- getByDeck(deckId) → Stream<List<Card>>
- getById(id) → Future<Card?>
- getDueCards(deckId, {limit}) → Future<List<Card>>
- create(card) → Future<Card>
- createBatch(cards) → Future<List<Card>>
- update(card) → Future<void>
- delete(id) → Future<void>
- updateSRS(cardId, rating) → Future<void>

StudySessionRepository:
- create(session) → Future<StudySession>
- complete(sessionId, stats) → Future<void>
- getByDeck(deckId) → Future<List<StudySession>>
- getByDateRange(start, end) → Future<List<StudySession>>
- getTodayStats() → Future<TodayStats>
- getStreak() → Future<int>

Chạy build_runner để generate Isar schemas và freezed classes.
Viết unit tests cho mỗi repository với mock Isar instance.
```

---

### PROMPT 1.4 — Router & Navigation

```
Implement GoRouter navigation cho MemoX.

FILE: lib/core/router/app_router.dart

Route tree:
/                          → HomeScreen (folder list)
/folder/:folderId          → FolderDetailScreen
/folder/:folderId/deck/:deckId → DeckDetailScreen
/deck/:deckId/study/review → ReviewModeScreen
/deck/:deckId/study/match  → MatchModeScreen
/deck/:deckId/study/guess  → GuessModeScreen
/deck/:deckId/study/recall → RecallModeScreen
/deck/:deckId/study/fill   → FillModeScreen
/statistics                → StatisticsScreen
/settings                  → SettingsScreen
/card/create/:deckId       → CardCreateScreen
/card/edit/:cardId         → CardEditScreen

Cấu hình:
- Bottom navigation dùng StatefulShellRoute cho 4 tabs:
  Home (/), Library, Progress (/statistics), Settings (/settings)
- Study mode screens là fullscreen routes (không có bottom nav)
- Folder/Deck detail push lên stack trong Home tab
- Custom page transitions:
  + Folder → Subfolder: slide left (300ms)
  + Deck → Study mode: fade up (200ms)  
  + Study complete → back: fade out (150ms)
- Deep linking support
- Redirect logic: nếu deck không tồn tại → redirect về home

FILE: lib/core/router/route_names.dart
- Tất cả route names là static const strings
- Helper methods: goToFolder(id), goToDeck(id), goToStudy(deckId, mode)

Tạo Riverpod provider cho router instance.
Tạo placeholder screens cho mọi route (chỉ hiển thị route name + params).
Verify tất cả routes navigate đúng.
```

---

## PHASE 2: CORE FEATURES

### PROMPT 2.1 — Folder Management (Business Logic + UI)

```
Implement tính năng Folder Management cho MemoX.

=== BUSINESS RULES (CRITICAL) ===
1. Root folders: hiển thị ở home screen, parentId = null
2. Mỗi folder có thể chứa SUBFOLDERS hoặc DECKS — KHÔNG BAO GIỜ CẢ HAI
3. Logic xác định folder type:
   - hasSubfolders(id) == true → chỉ cho tạo thêm subfolder
   - hasDecks(id) == true → chỉ cho tạo thêm deck
   - Cả hai == false (folder trống) → cho tạo subfolder HOẶC deck
     (lần tạo đầu tiên quyết định type của folder)
4. Khi xóa folder: cascade delete tất cả subfolders → decks → cards → reviews
5. Folder depth không giới hạn nhưng UI nên warning khi > 3 levels
6. Reorder bằng drag-and-drop (lưu sortOrder)

=== DOMAIN LAYER ===

FILE: lib/features/folders/domain/usecases/
- GetRootFoldersUseCase → Stream<List<FolderEntity>>
- GetSubfoldersUseCase(parentId) → Stream<List<FolderEntity>>
- CreateFolderUseCase(name, parentId?, color)
  + Validate: name not empty, name unique within same parent
- DeleteFolderUseCase(id) 
  + Show confirmation with count of items to be deleted
  + Cascade: subfolders → decks → cards → reviews
- CanCreateSubfolderUseCase(folderId) → bool
  + Returns false if folder already has decks
- CanCreateDeckUseCase(folderId) → bool
  + Returns false if folder already has subfolders
- GetFolderBreadcrumbUseCase(folderId) → List<FolderEntity>
  + Walk up parentId chain to build breadcrumb path

=== PRESENTATION LAYER ===

FILE: lib/features/folders/presentation/providers/
- foldersProvider: watch root folders stream
- subfolderProvider(parentId): watch subfolders stream
- folderDetailProvider(id): single folder + computed metadata
  + contentType: ContentType { subfolders, decks, empty }
  + totalCards: int (recursive count)
  + masteryPercentage: double (recursive average)
- canCreateSubfolderProvider(id): bool
- canCreateDeckProvider(id): bool

FILE: lib/features/folders/presentation/screens/
- HomeScreen:
  + Top bar: "MemoX" + search + avatar
  + Greeting với due card count (từ all decks recursive)
  + "Review now →" link → navigate tới first deck with due cards
  + FolderListView: vertical list of root folders
  + Mỗi FolderTile: icon, name, subtitle, mastery ring
  + FAB: "+" → CreateFolderDialog
  + Empty state khi không có folders

- FolderDetailScreen:
  + App bar: back + folder name + breadcrumb
  + Status indicator bar (contains X subfolders / contains X decks)
  + Content: SubfolderListView HOẶC DeckListView dựa trên contentType
  + FAB: "+" → label thay đổi theo context (New Subfolder / New Deck)
  + Khi folder empty và tap FAB: show bottom sheet chọn 
    "Create Subfolder" hoặc "Create Deck"
  + Constraint message ở bottom khi cần

FILE: lib/features/folders/presentation/widgets/
- FolderTile: stateless, nhận FolderEntity, onTap, onLongPress
- FolderMasteryRing: circular progress, 32dp, animated
- CreateFolderDialog: name field + color picker (6 options) + Create button
- FolderTypeChooserSheet: bottom sheet cho empty folder
- DeleteFolderConfirmDialog: shows cascade count

Tất cả widget dưới 80 dòng. Dùng flutter_animate cho enter animations
(fadeIn + slideY, stagger 50ms giữa list items).

Viết widget test cho:
- FolderTile hiển thị đúng data
- CreateFolderDialog validate input
- Business rule: không cho tạo deck khi đã có subfolders
```

---

### PROMPT 2.2 — Deck & Card Management

```
Implement Deck và Card management cho MemoX.

=== DECK FEATURE ===

Domain:
- GetDecksByFolderUseCase(folderId) → Stream<List<DeckEntity>>
- CreateDeckUseCase(name, folderId, color?, tags?)
  + Validate: name not empty, check canCreateDeck(folderId)
- DeleteDeckUseCase(id) → cascade delete cards + reviews
- GetDeckStatsUseCase(deckId) → DeckStats
  record DeckStats(int total, int due, int known, int learning, int newCards, double mastery)

Presentation:
- DeckListView: vertical list trong FolderDetailScreen
- DeckTile widget:
  + Outlined card, 12dp radius
  + Name (16sp, 500w) + "42 cards · 8 due today"
  + Mastery progress bar (4dp, rounded, coral→amber→teal gradient)
  + Tag chips (nếu có)
  + Entire card tappable → navigate to DeckDetailScreen
- CreateDeckDialog: name + description + color + tags input

DeckDetailScreen:
- Collapsing header: deck name + breadcrumb
- Stats row: 4 items (Total | Due | Known | New)
- "Study X due cards" primary button (full width, 52dp)
- "or choose a study mode" text → opens StudyModeSheet
- StudyModeSheet: bottom sheet, 5 mode rows
  Mỗi row: emoji circle + mode name + description + arrow
  Tap → navigate to /deck/:id/study/:mode
- Card list section:
  + Search bar (sticky)
  + Sort: date, alpha, status
  + CardListTile: front text + status dot (green/amber/gray)
  + Tap to expand → show front + back inline
- FAB: "+" → navigate to CardCreateScreen

=== CARD FEATURE ===

Domain:
- GetCardsByDeckUseCase(deckId) → Stream<List<CardEntity>>
- CreateCardUseCase(front, back, deckId, hint?, example?, tags?)
- CreateCardsBatchUseCase(rawText, separator, deckId)
  + Parse "front<sep>back" per line
  + Return (List<Card> parsed, List<String> errors)
- UpdateCardUseCase, DeleteCardUseCase
- GetDueCardsUseCase(deckId, {limit: 20}) → List<CardEntity>
  + Filter: nextReviewDate <= now OR status == newCard
  + Sort: overdue first, then new cards

Presentation:
- CardCreateScreen (full screen dialog):
  + Cancel / "New Card" / Save
  + Front field (multiline, 3 lines, required)
  + Back field (multiline, 4 lines, required)
  + "Add more details +" expander → hint, example, tags
  + "Add another" switch
  + Batch mode toggle: Single | Batch
    Batch: large textarea + separator chips (Tab, |, ,) + preview count
  + Save validates then pops or clears (if "add another")
- CardEditScreen: same layout, pre-filled, Save updates

Widget tests:
- DeckTile displays correct stats
- CardCreateScreen validates empty fields
- Batch parser handles edge cases (empty lines, missing separator)
```

---

## PHASE 3: STUDY MODES

### PROMPT 3.1 — SRS Engine (SM-2 Algorithm)

```
Implement SM-2 Spaced Repetition algorithm cho MemoX.

FILE: lib/features/study/domain/srs/srs_engine.dart

Class SRSEngine (pure Dart, no Flutter dependency, fully testable):

Method: processReview(CardEntity card, ReviewRating rating) → SRSResult

record SRSResult(
  double newEaseFactor,
  int newInterval,       // days
  int newRepetitions,
  DateTime nextReviewDate,
  CardStatus newStatus,
)

SM-2 Algorithm implementation:
1. Quality mapping:
   - again → quality = 0 (complete failure)
   - hard → quality = 2 (correct with serious difficulty)
   - good → quality = 3 (correct with some difficulty)
   - easy → quality = 5 (perfect response)

2. If quality < 3 (again):
   - repetitions = 0
   - interval = 1 (review tomorrow)
   - status = learning

3. If quality >= 3:
   - repetitions += 1
   - if repetitions == 1: interval = 1
   - if repetitions == 2: interval = 6
   - if repetitions > 2: interval = round(previousInterval * easeFactor)
   - Update easeFactor: EF' = EF + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))
   - easeFactor = max(1.3, EF')

4. Status transitions:
   - newCard → learning (after first review)
   - learning → reviewing (after 2+ correct consecutive)
   - reviewing → mastered (after easeFactor > 2.5 AND interval > 21)
   - mastered → reviewing (if quality < 3)
   - Any → learning (if quality == 0)

5. nextReviewDate = now + Duration(days: interval)

Method: getNextReviewTimes(CardEntity card) → Map<ReviewRating, String>
- Returns human-readable next review time for each rating option
- "< 1m", "10m", "1d", "4d", etc.
- Used to display below rating buttons in Review mode

Method: processRecallSelfRating(CardEntity card, SelfRating rating) → SRSResult
- missed → same as ReviewRating.again
- partial → same as ReviewRating.hard
- gotIt → same as ReviewRating.good

Method: processFillResult(CardEntity card, bool isCorrect) → SRSResult
- correct → ReviewRating.good
- wrong → ReviewRating.again

Method: processGuessResult(CardEntity card, bool isCorrect) → SRSResult
- correct → ReviewRating.good
- wrong → ReviewRating.again

Method: processMatchResult(CardEntity card, int attempts) → SRSResult
- 1 attempt (first try correct) → ReviewRating.easy
- 2 attempts → ReviewRating.good
- 3+ attempts → ReviewRating.hard

FILE: lib/features/study/domain/srs/fuzzy_matcher.dart
Class FuzzyMatcher:
- match(userAnswer, correctAnswer) → MatchResult
- enum MatchResult { exact, close, wrong }
- Logic:
  + Normalize: trim, lowercase, remove extra spaces
  + exact: normalized strings match
  + close: Levenshtein distance <= 2 OR only diff is accents/case
  + wrong: everything else
- levenshteinDistance(a, b) → int (standard DP implementation)

Viết comprehensive unit tests:
- Test mỗi rating path trong SM-2
- Test status transitions
- Test edge cases: easeFactor minimum, first review, long intervals
- Test fuzzy matcher: exact, close typo, accent diff, completely wrong
- Test với chuỗi tiếng Nhật (Unicode handling)
```

---

### PROMPT 3.2 — Review Mode (Flip Card)

```
Implement Review Mode cho MemoX — chế độ study chính.

=== STATE MANAGEMENT ===

FILE: lib/features/study/presentation/providers/review_provider.dart

@riverpod class ReviewSession:

State: ReviewState (freezed)
- cards: List<CardEntity> (loaded from due cards)
- currentIndex: int
- isFlipped: bool
- isComplete: bool
- ratings: Map<String, ReviewRating> (cardId → rating)
- sessionStats: SessionStats

Actions:
- startSession(deckId) → load due cards, shuffle, reset state
- flipCard() → toggle isFlipped
- rateCard(ReviewRating) → 
  1. Call SRSEngine.processReview()
  2. Update card in repository
  3. Record review in CardReviewModel
  4. If last card → mark complete, save StudySession
  5. Else → advance to next card, reset flip

Computed:
- currentCard → cards[currentIndex]
- progress → currentIndex / cards.length
- nextReviewTimes → SRSEngine.getNextReviewTimes(currentCard)
- sessionDuration → DateTime.now - startTime

=== UI ===

FILE: lib/features/study/presentation/screens/review_mode_screen.dart

Layout (tuân thủ design spec):
1. Top bar:
   - Close (×) → confirmation dialog if session in progress
   - Progress text: "4 / 20" (14sp, secondary)
   - Progress bar (3dp, primary on gray, animated width)

2. FlashcardWidget (center, ~340w × ~400h):
   - AnimatedSwitcher + custom flip transition
   - Front: term centered, 22sp 600w
     "Tap to flip" hint — hiển thị 3 lần đầu rồi fade away vĩnh viễn
     (dùng SharedPreferences flag)
   - Back: definition 17sp 400w, example italics nếu có
   - Flip: Transform matrix4 rotation Y, 350ms ease-in-out
     Scale 1.0 → 0.96 → 1.0 tại midpoint
   - GestureDetector: tap to flip

3. RatingButtonsRow (fade in sau khi flip):
   - Animated visibility: fadeIn + slideUp 200ms
   - 4 buttons: Again (coral outline), Hard (amber outline), 
     Good (primary filled tonal), Easy (teal outline)
   - Below each: next review time text (11sp)
   - "Good" visually emphasized (filled vs outlined)

4. SwipeGestureDetector (wrap card):
   - GestureDetector with onHorizontalDragUpdate/End
   - Swipe right (dx > 100): green overlay 15% + "Good" label
   - Swipe left (dx < -100): coral overlay 15% + "Again" label
   - Overlay opacity proportional to drag distance
   - On release past threshold: trigger corresponding rating

5. SessionCompleteView (shared widget from shared/widgets/feedback/):
   - Replaces card area when isComplete
   - Pass stats: cards reviewed, accuracy, time
   - Primary action: "Done" → pop to deck detail
   - Secondary action: "Study more" → restart with remaining due cards
   - Widget handles: checkmark animation, layout, button styles

Animations dùng flutter_animate:
- Card enter: fadeIn(200ms) + scale(begin: 0.97, 200ms)
- Card transition: fadeOut → fadeIn (crossfade)  
- Rating buttons: fadeIn(200ms, delay: 100ms) + slideY(begin: 0.1)
- Complete view: fadeIn(300ms) + scale(begin: 0.95)

Test:
- Widget test: flip animation triggers
- Widget test: rating button advances to next card
- Unit test: session completes correctly
- Unit test: SRS updates saved to DB
```

---

### PROMPT 3.3 — Match Mode

```
Implement Match Mode cho MemoX — ghép cặp term-definition.

=== GAME LOGIC ===

FILE: lib/features/study/domain/match/match_engine.dart

Class MatchEngine:
- generateGame(List<CardEntity> cards, {pairsPerRound: 5}) → MatchGame
  + Select min(5, cards.length) random cards
  + Create term list (shuffled) and definition list (shuffled independently)
  + Return MatchGame record

record MatchGame(
  List<MatchItem> terms,      // shuffled terms
  List<MatchItem> definitions, // shuffled definitions  
  Map<String, String> correctPairs, // termId → definitionId
)

record MatchItem(String id, String text, MatchItemType type)
enum MatchItemType { term, definition }

- checkMatch(termId, definitionId) → bool
- All pairs matched → game complete

=== STATE ===

FILE: lib/features/study/presentation/providers/match_provider.dart

@riverpod class MatchSession:

State: MatchState (freezed)
- game: MatchGame
- selectedTermId: String? 
- selectedDefinitionId: String?
- matchedPairIds: Set<String> (matched term IDs)
- mistakes: int
- startTime: DateTime
- isComplete: bool
- lastResult: MatchAttemptResult? (correct/wrong, for animation trigger)
- comboCount: int

Actions:
- startGame(deckId) → load cards, generate game
- selectItem(MatchItem) →
  + If same column as already selected → replace selection
  + If term selected + definition selected → checkMatch
  + If correct: add to matchedPairIds, combo++, 
    update SRS for card (processMatchResult with attempts=1)
  + If wrong: mistakes++, combo=0, clear selections after 300ms delay
  + If all matched → complete, save session
- deselectItem() → clear current selection

=== UI ===

FILE: lib/features/study/presentation/screens/match_mode_screen.dart

Layout:
1. Top bar: Close(×) + "Match" + timer (simple text "1:24", 16sp mono)
   Below: "4 pairs left" (13sp caption)

2. Two-column layout (Row with 2 Expanded columns):
   - Left: terms, Right: definitions
   - 4-5 items per column
   - Each MatchItemCard:
     + Outlined card, 12dp radius, 14sp text, 12dp padding
     + States:
       - normal: surface bg, secondary text
       - selected: primary tonal bg, primary text, scale 1.02
       - matched: animated fadeOut + scaleDown, then removed from list
       - wrong: red border 200ms → shake (horizontalShake 4dp, 300ms)
     + AnimatedContainer for smooth state transitions
   - Items reposition smoothly when matched pairs removed
     (AnimatedList or implicitly animated Column)

3. Completion:
   - "All matched!" (18sp, 600w)
   - Time, mistakes, star rating (3/2/1 based on mistakes)
   - "Play again" (outlined) + "Done" (filled)

Animations:
- Correct match: both items scale down + fade (300ms), 
  remaining items slide to fill gap (200ms)
- Wrong match: shake animation, brief red border
- All flutter_animate, no custom AnimationControllers

Test:
- Match engine generates valid pairs
- Selection logic: can't select two from same column
- Match detection works correctly
- Game completes when all pairs matched
```

---

### PROMPT 3.4 — Guess Mode

```
Implement Guess Mode cho MemoX — multiple choice, xem definition đoán term.

=== LOGIC ===

FILE: lib/features/study/domain/guess/guess_engine.dart

Class GuessEngine:
- generateQuestion(CardEntity target, List<CardEntity> allCards) → GuessQuestion
  + correctAnswer = target.front (term)
  + distractors = 3 random cards from same deck (khác target)
    fallback: nếu deck < 4 cards, dùng "???" placeholders
  + Shuffle 4 options
  + Return GuessQuestion

record GuessQuestion(
  String definition,     // the prompt (card.back)
  List<GuessOption> options,
  int correctIndex,
)
record GuessOption(String text, String cardId, bool isCorrect)

=== STATE ===

@riverpod class GuessSession:

State: GuessState (freezed)
- cards: List<CardEntity>
- currentIndex: int
- currentQuestion: GuessQuestion
- selectedOptionIndex: int? (null = chưa chọn)
- isAnswered: bool
- isCorrect: bool?
- streak: int
- bestStreak: int
- results: List<bool>
- isComplete: bool

Actions:
- startSession(deckId) → load cards, shuffle, generate first question
- selectOption(index) →
  + If already answered → ignore
  + Mark as answered
  + If correct: streak++, bestStreak = max, update SRS (correct)
  + If wrong: streak = 0, update SRS (wrong)
  + If correct: auto-advance after 1.5s delay
  + If wrong: wait for user tap to continue
- nextQuestion() → advance index, generate new question
- skipQuestion() → add card back to end of queue, advance

=== UI ===

FILE: lib/features/study/presentation/screens/guess_mode_screen.dart

Layout:
1. Top bar: Close(×) + "5/20" + streak chip (🔥5, chỉ hiện khi streak>=2)
   + Progress bar (3dp)

2. QuestionCard (upper 40%, surface-variant, 16dp radius, 20dp padding):
   - "What is this?" label (12sp, caption)
   - Definition text (18sp, centered)

3. OptionButtons (4 full-width outlined buttons, stacked, 8dp gap):
   - 52dp height, 12dp radius, left-aligned text 15sp
   - Prefix: "A.", "B.", "C.", "D." (secondary color)
   - States sau khi answer:
     + Correct selected: teal fill + white checkmark right
     + Wrong selected: coral fill + white × right
     + Correct (khi chọn sai): teal fill + checkmark (chỉ ra đáp án đúng)
     + Others: fade to 40% opacity
   - Animation: color transition 200ms ease

4. Bottom: "Skip →" text button (13sp secondary)

5. Completion: stats + "16/20 correct (80%)" + "Best streak: 7"

Streak animation:
- Khi streak tăng: chip scale pulse 1.0→1.2→1.0 (200ms)
- Khi streak >= 5: thêm subtle glow

Test:
- GuessEngine generates 4 unique options
- Correct answer is always in options
- Streak tracking works
- Skip re-queues card
```

---

### PROMPT 3.5 — Recall Mode

```
Implement Recall Mode cho MemoX — free recall, tự viết và tự đánh giá.

=== STATE ===

@riverpod class RecallSession:

State: RecallState (freezed)
- cards: List<CardEntity>
- currentIndex: int
- userAnswer: String
- isRevealed: bool (đã show answer chưa)
- selfRating: SelfRating? (chọn sau khi reveal)
- results: List<RecallResult>
- isComplete: bool

record RecallResult(String cardId, String userAnswer, SelfRating rating)

Actions:
- startSession(deckId) → load cards, shuffle
- updateAnswer(text) → update userAnswer (for text field binding)
- revealAnswer() → 
  + Chỉ cho phép khi userAnswer.trim().isNotEmpty
  + Set isRevealed = true
- rateSelf(SelfRating) →
  + Save rating
  + Call SRSEngine.processRecallSelfRating()
  + Update card in DB
  + Record review
  + Delay 800ms → advance to next or complete
- canReveal → userAnswer.trim().isNotEmpty

=== UI ===

FILE: lib/features/study/presentation/screens/recall_mode_screen.dart

Layout:
1. Top bar: Close(×) + "Recall" (16sp 500w) + "3/15" + progress bar

2. PromptCard (upper area, surface-variant, 16dp radius, 20dp padding):
   - "What do you know about:" (12sp caption uppercase, 0.06em spacing)
   - Term: 22sp, 600w, centered, primary text
   - Category chip nếu có (11sp, outlined, secondary)
   - Deliberately sparse — no hints
   - Enter animation: fadeIn + scale(0.97→1.0, 200ms)

3. WritingArea (below prompt):
   - Before reveal:
     + TextField multiline, 4 visible lines (~140dp), expandable
     + Floating label: "Your answer"
     + Placeholder: "Write everything you remember..."
     + 16sp text, 1.6 line-height
   - "Show answer" button below (full width, outlined, 48dp)
     + Eye icon + text
     + Disabled (40% opacity) until user types ≥1 char
     + Enabled: subtle border animation

4. ComparisonView (replaces writing area after reveal):
   - Crossfade transition (out 150ms, in 200ms + slideUp)
   
   YOUR ANSWER card:
   - "Your answer" label (12sp caption)
   - Surface card, 12dp radius, 16dp padding
   - User text 15sp, preserved exactly
   - Left border: 3dp neutral gray
   
   CORRECT ANSWER card:
   - "Complete answer" label (12sp caption)  
   - Surface-variant card, 12dp radius, 16dp padding
   - Full answer 15sp
   - Left border: 3dp primary color
   - Max height 200dp with scroll if long

5. SelfAssessment (below comparison, 20dp gap):
   - "How well did you recall?" (13sp caption centered)
   - SegmentedButton full width, 3 segments:
     "Missed" | "Partial" | "Got it"
   - Default: none selected (neutral)
   - On select: segment tints (coral/amber/teal)
   - After select: 800ms pause → next card
   - This is ONLY way to proceed — no skip

6. SessionComplete:
   - "15 cards recalled"
   - "Got it: 8 · Partial: 5 · Missed: 2"  
   - "Done" + "Review missed cards" link

Test:
- Cannot reveal without typing
- Self-rating advances to next card
- SRS updates match rating mapping
- Session stats calculated correctly
```

---

### PROMPT 3.6 — Fill Mode

```
Implement Fill Mode cho MemoX — gõ đáp án vào chỗ trống.

=== LOGIC ===

FILE: lib/features/study/domain/fill/fill_engine.dart

Class FillEngine:
- generatePrompt(CardEntity card) → FillPrompt
  + Tạo câu với blank từ card.front hoặc card.back
  + Nếu card có example → dùng example với term thay bằng ____
  + Nếu không → "The answer for '[front]' is ________"
  + correctAnswer = giá trị bị blank

record FillPrompt(
  String sentenceWithBlank,  // "The Japanese word for 'water' is ________"
  String correctAnswer,       // "みず"
  String? hint,               // first letter + blanks: "み _ _"
  int answerLength,           // để sizing underline
)

- checkAnswer(userInput, correctAnswer) → FillResult
  + Dùng FuzzyMatcher.match()
  + Return FillResult

enum FillResult { correct, close, wrong }

=== STATE ===

@riverpod class FillSession:

State: FillState (freezed)
- cards: List<CardEntity>
- currentIndex: int
- currentPrompt: FillPrompt
- userInput: String
- result: FillResult? (null = chưa submit)
- isRetrying: bool (wrong → phải gõ lại đúng)
- retryCount: int
- showHint: bool
- streak: int
- results: List<FillCardResult>
- isComplete: bool

record FillCardResult(
  String cardId,
  FillResult firstAttemptResult,
  bool acceptedAsClose,
  int retryCount,
)

Actions:
- startSession(deckId) → load, shuffle, generate first prompt
- updateInput(text) → update userInput
- submitAnswer() →
  + If userInput.trim().isEmpty → ignore
  + result = FillEngine.checkAnswer(userInput, correctAnswer)
  + If correct:
    - Update SRS (correct), record review
    - Auto-advance after 1.2s
  + If close:
    - Show comparison, wait for user choice
  + If wrong:
    - Show correct answer
    - Clear input after 500ms
    - Set isRetrying = true, retryCount++
    - User must type correct answer to proceed
- acceptClose() → treat as correct, advance
- rejectClose() → treat as wrong, enter retry
- retrySubmit() → 
  + Check if userInput matches correctAnswer (exact or close)
  + If matches: advance to next
  + If retryCount >= 2: show "Skip" option
- toggleHint() → showHint = true (one-way)
- skipCard() → only available after 2 failed retries, advance

=== UI ===

FILE: lib/features/study/presentation/screens/fill_mode_screen.dart

Layout:
1. Top bar: Close(×) + "Fill" (16sp 500w) + "7/20" + progress bar
   Streak chip (🔥5) appears at right when streak >= 3

2. QuestionCard (upper 40%, surface-variant, 16dp radius, 24dp padding):
   - Sentence 18sp, 400w, 1.6 line-height
   - Blank rendered inline: underline 2dp thick, primary color
     Width proportional to answer length (~80dp short, ~140dp long)
     Gentle pulse animation (opacity 60%→100%, 1.5s, ease-in-out)
   - After correct: blank fills with answer in teal color, pulse stops
   - "Show hint" link below card (13sp secondary) → reveals "m _ _ _"
     One-way: once shown, stays shown

3. InputArea (20dp below card):
   - SingleLine TextField, 52dp height, 12dp radius
   - Auto-focused (keyboard opens immediately)
   - Floating label: "Your answer"
   - Placeholder: "Type your answer..."
   - Text 17sp, centered
   - Check button integrated right side of field:
     + 36dp height, 8dp radius, primary tonal
     + Arrow icon (→) 20dp
     + Disabled until input not empty
   - Enter key = submit

4. Feedback (below input, 8dp gap):
   
   CORRECT:
   - Input border → teal (200ms)
   - Checkmark appears left of text in input
   - Blank in card fills with teal text
   - Scale pulse on filled word (1.0→1.05→1.0, 300ms)
   - Auto-advance 1.2s

   CLOSE:
   - Input border → amber (200ms)
   - Surface card below with amber left border (3dp):
     "Almost! Correct spelling:" + correct answer (16sp 500w)
     Inline diff: wrong chars coral, correct chars teal
   - Two text buttons: "Accept anyway" (teal) | "Mark as wrong" (coral)

   WRONG:
   - Input border → coral (200ms)
   - Surface card below with coral left border (3dp):
     "The correct answer is:" + answer (16sp 500w primary)
   - Input clears after 500ms
   - Placeholder becomes "Type the correct answer to continue"
   - Must type correctly to proceed
   - After 2 failed retries: "Skip" text button appears (13sp secondary bottom)

5. Card transitions: crossfade (out 150ms, in 200ms), input clears + refocuses

6. SessionComplete:
   - "20 cards completed"
   - "14 correct first try (70%)"
   - "4 close matches accepted"  
   - "2 needed retry"
   - "🔥 Longest streak: 8"
   - "Done" + "Practice mistakes" link
   - Expandable mistakes list

Keyboard handling:
- Auto-focus on every new card
- TextInputType.text default, TextInputType.number if answer is numeric
- IME support cho Japanese input (important!)
- TextField scrolls into view khi keyboard covers

Test:
- FillEngine generates valid prompts
- Fuzzy matcher: exact, close (typo), wrong
- Retry mechanic: must type correctly
- Skip only after 2 retries
- Streak counter
- Unicode/Japanese input handling
```

---

## PHASE 4: STATISTICS & SETTINGS

### PROMPT 4.1 — Statistics Dashboard

```
Implement Statistics/Progress screen cho MemoX.

=== DATA AGGREGATION ===

FILE: lib/features/statistics/domain/usecases/
- GetStudyStatsUseCase(DateRange) → StudyStats:
  record StudyStats(
    int streak,
    int cardsToday, int minutesToday,
    List<DailyActivity> weeklyActivity,  // 7 items
    MasteryBreakdown mastery,
    Map<StudyMode, double> modeUsage,    // mode → percentage
    List<DifficultCard> difficultCards,
  )

- GetStreakUseCase() → int
  + Count consecutive days with at least 1 study session
  + Walk backwards from today

- GetWeeklyActivityUseCase() → List<DailyActivity>
  record DailyActivity(DateTime date, int cardsStudied, int minutes)

- GetMasteryBreakdownUseCase() → MasteryBreakdown
  record MasteryBreakdown(int known, int learning, int newCards, int total)

- GetDifficultCardsUseCase({limit: 5}) → List<DifficultCard>
  + Cards with lowest accuracy (most "again" ratings)
  record DifficultCard(CardEntity card, String deckName, double accuracy)

=== UI ===

FILE: lib/features/statistics/presentation/screens/statistics_screen.dart

Scrollable, single column:

1. Header: "Your Progress" (20sp 600w)
   Period tabs: "Week · Month · All time" (text tabs, underline active)

2. StreakHeroCard (surface-variant, 16dp radius):
   - Large streak number (48sp 600w primary) + "day streak 🔥"
   - "Today: 23 cards · 18 min" (14sp caption)
   - Number animates counting up on load (400ms, dùng TweenAnimationBuilder)

3. WeeklyBarChart (custom painted, ~120dp height):
   - 7 bars, Mon-Sun
   - Today highlighted primary color, others surface-variant
   - No axis lines, no grid — just bars + day labels "M T W T F S S"
   - Tap bar → show count tooltip above
   - Bars animate growing up on load (stagger 50ms)
   - CustomPainter implementation (không dùng chart library nặng)

4. MasteryDonutChart (~160dp diameter):
   - 3 segments: Known (teal), Learning (amber), New (gray)
   - Center: total card count (24sp 600w)
   - Legend below: 3 items row, color dot + label + count
   - CustomPainter with animated segments (sweep angle tween, 600ms)

5. ModeUsageChart (horizontal bars):
   - 5 rows, one per mode
   - Mode name left, percentage right, bar between
   - All bars primary color (same hue, different lengths)
   - Each row ~36dp height
   - Simple Container with animated width

6. DifficultCardsSection (collapsible):
   - "Cards to focus on" header + expand toggle
   - Starts collapsed
   - 3-5 rows: term (15sp) + accuracy % (coral if <50%)
   - "Practice these" text button → creates a study session with just these cards

Spacing: 32dp between sections.
All numbers animate counting up.
Respect light/dark theme.

Test:
- Streak calculation: consecutive days, handles gaps
- Stats aggregate correctly from session data
- Empty state when no study history
```

---

### PROMPT 4.2 — Settings

```
Implement Settings screen cho MemoX.

=== PERSISTENCE ===

FILE: lib/features/settings/data/models/app_settings.dart
Class AppSettings (freezed, persisted with SharedPreferences):
- ThemeMode themeMode (system/light/dark)
- int seedColorValue (one of 6 presets)
- int dailyGoal (default 20, range 10-200, step 10)
- int sessionLimitMinutes (default 15, options: 5,10,15,20,30)
- double autoAdvanceDelay (default 1.5, options: 1.0, 1.5, 2.0, 3.0)
- bool studyReminder (default false)
- TimeOfDay? reminderTime
- bool streakReminder (default true)

FILE: lib/features/settings/data/repositories/settings_repository.dart
- load() → AppSettings
- save(AppSettings) → void
- Individual setters for each field

FILE: lib/features/settings/presentation/providers/settings_provider.dart
@riverpod class SettingsNotifier:
- Exposes AppSettings as state
- Methods for each setting change
- Theme change triggers app-wide rebuild via ProviderScope

=== UI ===

FILE: lib/features/settings/presentation/screens/settings_screen.dart

M3 preference list, grouped:

Section headers: 12sp uppercase, 0.08em spacing, secondary, 32dp top margin

APPEARANCE:
- Theme: 3 tappable cards (sun/moon/auto icon)
  Selected: primary border
- App color: 6 circles (40dp), selected has checkmark
  Colors: Indigo(5C6BC0), Teal(4DB6AC), Rose(E57373), 
          Amber(FFB74D), Slate(78909C), Sage(81C784)
  Changing color → rebuilds ColorScheme.fromSeed() app-wide

STUDYING:
- Daily goal: "20 cards/day" + stepper (−/+), range 10-200
- Session limit: "15 minutes" + stepper, options 5/10/15/20/30
- Auto-advance: "1.5s" dropdown

NOTIFICATIONS:
- Study reminder: M3 Switch + TimePicker khi enabled
- Streak reminder: M3 Switch
- (Schedule notifications with flutter_local_notifications)

DATA:
- Export cards (JSON): tap → generate JSON of all folders/decks/cards
  → share via Share sheet
- Import from file: tap → FilePicker → parse JSON → import
- Clear study history: tap → confirmation dialog (coral text)
  → delete all StudySessions + CardReviews, keep cards

Each row: 52dp height, no dividers (section headers separate).
Subtle press ripple on tappable rows.

Export format (JSON):
{
  "version": 1,
  "exportDate": "...",
  "folders": [...],
  "decks": [...],
  "cards": [...]
}
Import validates version and handles missing fields gracefully.

Test:
- Settings persist across app restart
- Theme change applies immediately
- Color change regenerates scheme
- Export/Import round-trip preserves data
- Clear history doesn't delete cards
```

---

## PHASE 5: POLISH & INTEGRATION

### PROMPT 5.1 — Search & Empty States

```
Implement global search và tất cả empty states cho MemoX.

=== SEARCH ===

SearchUseCase:
- search(query) → SearchResults
  record SearchResults(
    List<FolderEntity> folders,
    List<DeckEntity> decks,
    List<CardEntity> cards,
  )
- Search trong: folder names, deck names + tags, card front + back
- Isar full-text search hoặc manual CONTAINS filter
- Debounce 300ms, minimum 2 characters

SearchScreen (hoặc overlay):
- TextField auto-focused, "Search folders, decks, cards..."
- Results grouped by type: Folders / Decks / Cards
- Each result: icon + title + subtitle (parent path) + tap to navigate
- Empty search: "No results for '[query]'"
- Recent searches (last 5, stored in SharedPreferences)

=== EMPTY STATES (all screens) ===

Mỗi empty state: icon (64dp outlined, secondary) + title + subtitle + optional CTA

Home (no folders):
  📁 "No folders yet" / "Create your first folder to start organizing" / [Create Folder]

Folder detail (no subfolders/decks):
  📂 "This folder is empty" / "Add subfolders or decks to get started" / [Choose type]

Deck detail (no cards):
  🃏 "No cards yet" / "Add your first flashcard" / [Add Card]

Study (no due cards):
  ✅ "All caught up!" / "No cards due for review. Great job!" / [Study anyway]

Statistics (no history):
  📊 "No study data yet" / "Complete a study session to see your progress" / [Start studying]

Search (no results):
  🔍 "No results" / "Try different keywords"

Animations: fadeIn(300ms) + scale(begin: 0.9, 300ms) cho mỗi empty state.
Tất cả dùng reusable EmptyStateWidget(icon, title, subtitle, action?).
```

---

### PROMPT 5.2 — Final Integration & Testing

```
Final integration pass cho MemoX.

1. NAVIGATION FLOW VERIFICATION:
   - Home → Folder → Subfolder → Deck → Study mode → Complete → Back
   - Verify breadcrumbs update correctly at every level
   - Back button behavior: study mode shows "Exit session?" dialog
   - Bottom nav state preserved when switching tabs
   - Deep link: /deck/123/study/review opens correctly

2. DATA CONSISTENCY:
   - Delete folder → verify cascade (subfolders, decks, cards, reviews gone)
   - Delete deck → verify cards and reviews removed
   - Create card → deck card count updates immediately
   - Complete study → stats reflect immediately on Statistics screen
   - Verify Isar watchers trigger Riverpod stream updates

3. PERFORMANCE:
   - Profile with Flutter DevTools
   - Lazy load card lists (pagination 50 cards at a time)
   - Isar queries use proper indexes
   - Widget rebuilds minimized (select specific providers, not whole state)
   - Images cached if used

4. EDGE CASES:
   - Empty deck → study mode shows empty state, not crash
   - Single card in deck → Match mode handles gracefully (min 2 pairs)
   - Very long text in card → scrollable, doesn't overflow
   - Rapid tapping → debounce on rating buttons, submit buttons
   - Offline: app works 100% offline (Isar is local-first)
   - App killed mid-session → session not saved (acceptable)

5. ACCESSIBILITY:
   - Semantic labels on all icons and interactive elements
   - Sufficient color contrast (WCAG AA)
   - Touch targets >= 48dp
   - Screen reader: card content announced on flip

6. INTEGRATION TESTS:
   - Full flow: create folder → create deck → add cards → study review → check stats
   - Full flow: batch import cards → study fill mode → verify SRS update
   - Cascade delete verification
   - Settings change → theme applies → restart → persists

Chạy tất cả tests, fix failures, ensure 0 analyzer warnings.
```

---

## 📋 Tổng kết thứ tự thực hiện

```
PHASE 1 — Foundation (chạy tuần tự)
  1.1 Project setup & dependencies
  1.2 Theme system
  1.3 Data layer (models, DB, repositories)
  1.4 Router & navigation

PHASE 2 — Core Features
  2.1 Folder management (business logic + UI)
  2.2 Deck & Card management

PHASE 3 — Study Modes (có thể song song)
  3.1 SRS Engine (chạy TRƯỚC các mode)
  3.2 Review mode
  3.3 Match mode
  3.4 Guess mode
  3.5 Recall mode
  3.6 Fill mode

PHASE 4 — Supporting Features
  4.1 Statistics dashboard
  4.2 Settings

PHASE 5 — Polish
  5.1 Search & empty states
  5.2 Integration & testing
```

---

## 💡 Tips sử dụng

**Với Claude Code CLI:**
```bash
# Paste prompt vào, Claude Code sẽ tạo files trực tiếp
claude "$(cat prompt-1.1.txt)"

# Sau mỗi prompt, verify build
flutter analyze && flutter test
```

**Với Codex:**
- Paste từng prompt vào Codex agent
- Codex tốt cho code generation nhưng yếu hơn Claude về architecture decisions
- Nên dùng Codex cho Phase 3 (study modes) — repetitive pattern
- Dùng Claude Code cho Phase 1-2 — cần reasoning sâu về architecture

**Khi gặp lỗi:**
```
Build đang fail với error: [paste error]
Context: đang implement [prompt X.Y]
Fix lỗi này, giữ nguyên architecture đã thiết kế.
Không thay đổi cấu trúc thư mục hay state management approach.
```

**Khi cần convert UI từ v0:**
```
Đây là React component từ v0 cho [screen name]:
[paste v0 code]

Convert sang Flutter widget, tuân thủ:
- Theme system đã setup (AppTheme, AppDimensions, AppColors extension)
- Riverpod providers đã có cho screen này
- flutter_animate cho animations
- Tách thành small widgets (max 80 dòng/widget)
- Dùng const constructors mọi nơi có thể
```
