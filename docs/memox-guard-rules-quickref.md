# Guard Rules Quick Reference

Rules enforced by `python tools/guard/run.py`. All guards skip `test/`, `.g.dart`, `.freezed.dart` unless noted.

## Thresholds

- Widget `build()` body and widget class: max **80 lines** (warning)
- StatelessWidget/StatefulWidget/ConsumerWidget without `const` constructor → warning

## Forbidden — Code Style

**`no_else`** — Any `else` keyword → early return, guard clause, switch expression

**`import_direction`** — Domain must NOT import data/ or presentation/. Presentation must NOT import data/

## Forbidden — Hardcoded Values

All hardcoded literals are errors. Use design tokens:

- `Color(0x...)`, `Colors.xxx`, `.fromRGBO(`, `.fromARGB(`, `.withOpacity(N)`, `.withValues(alpha: N)` → `context.colors.*`, `context.customColors.*` — allowed in `core/theme/tokens/color_tokens.dart`, `core/theme/color_schemes/`
- `Duration(milliseconds/seconds/minutes: N)` → `DurationTokens.*` — allowed in `core/theme/tokens/duration_tokens.dart`
- `BorderRadius.circular(N)`, `BorderRadius.all(N)` → `RadiusTokens.*` — also flags wrong token type in BorderRadius
- `SizedBox(height/width: N)`, `size/width/height: N`, `EdgeInsets.all/symmetric/only(N)` → `SizeTokens.*`, `SpacingTokens.*`, `Gap.*`
- `fontSize: N` → `context.textTheme.*`, `context.appTextStyles.*`
- `title: Text('...')`, `label: '...'`, `hintText: '...'`, `tooltip: '...'`, `content: Text('...')` → `context.l10n.*`
- `Text('hardcoded')` → `context.l10n.*` (warning)

## Forbidden — Raw Widgets

**`shared_widget`** + **`button_usage`** — Forbidden outside `lib/shared/widgets/`:

`Card(` → AppCard · `.when(` → AppAsyncBuilder · `ElevatedButton(`/`FilledButton(`/`OutlinedButton(`/`TextButton(` → PrimaryButton/SecondaryButton · `CircularProgressIndicator(` → LoadingIndicator · `TextField(` → AppTextField · `ListTile(` → AppListTile · `SwitchListTile(` → AppSwitchTile · `PopupMenuButton(` → AppEditDeleteMenu · `InkWell(` → AppPressable/AppCard/TextLinkButton · `GestureDetector(` → AppTapRegion · `ScaffoldMessenger.of(` → Toast · `Dismissible(` → AppSlidableRow

## Forbidden — Text Style

**`text_style`** — Forbidden outside `lib/core/theme/`:
`TextStyle(`, `fontWeight: FontWeight.`, `fontFamily:`, `fontStyle:`, `letterSpacing: N`, `height: N` → use `context.textTheme.*` or `context.appTextStyles.*`

## Forbidden — Legacy Patterns

**`legacy_state_notifier`** — `StateNotifierProvider`, `extends StateNotifier`, `StateNotifier<` → `@riverpod`

**`l10n_source`** — `AppStrings.`, `core/constants/app_strings.dart` → `context.l10n.*`

**`records_patterns`** (warning) — `Tuple2`/`Tuple3`/`Pair` → Dart records. `if (x is T)` + `x as T` within 5 lines → `if (x case T y)`. `runtimeType` → pattern matching

## Forbidden — Riverpod Syntax

**`riverpod_syntax`** — In `core/providers/*.dart`, `core/router/app_router.dart`, `shared/providers/*.dart`, `features/*/presentation/providers/*.dart`:

Required: import `riverpod_annotation`, `part '{name}.g.dart'`, `@riverpod`/`@Riverpod(...)` annotation.
Forbidden: import `flutter_riverpod` in provider files, all legacy provider constructors (`Provider(`, `StateProvider(`, `FutureProvider(`, `StreamProvider(`, `NotifierProvider(`, `AsyncNotifierProvider(`, `StreamNotifierProvider(`, `ChangeNotifierProvider(`).
Infrastructure files must use `@Riverpod(keepAlive: true)`: `core/providers/{backup,database,datasource,repository,service,storage}_providers.dart`, `core/router/app_router.dart`.

## Required — Scaffold & Icons

**`screen_scaffold`** — `features/*/presentation/screens/*_screen.dart` must use `AppScaffold(` or `SliverScaffold(`, no raw `Scaffold(`

**`icon_style`** (warning) — `Icons.xxx` must end with `_outlined`/`_outline`. Exceptions: close, add, check, remove, arrow_back, arrow_forward, chevron_right, drag_handle, expand_more, more_vert, more_horiz

## Required — Responsive

**`responsive_text_scale`** — `lib/app.dart` and `test/test_helpers/test_app.dart` must contain: `MediaQuery(`, `textScaler:`, `TextScaler.linear(`, `ScreenType.of(context).textScaleFactor`

**`responsive_layout_test`** — deck_detail_screen and folder_detail_screen test files must contain `setSurfaceSize(` and `takeException()`

## Required — Refresh, Keyboard, Touch

**`refresh_retry`** — Files with `AppAsyncBuilder<` must have `onRetry:`. Refresh screens (home, folder_detail, deck_detail, statistics_content_view, settings_content_view) must have `AppRefreshIndicator(`/`AppRefreshScrollView(`/`onRefresh:`

**`safe_area_keyboard`** — Screen/dialog/view files with `AppTextField(`/`TextField(` must have keyboard-safe wrapper: `AppScaffold(`/`AppDialog(`/`SliverScaffold(`/`SingleChildScrollView(`/`ListView(`/`CustomScrollView(`

**`touch_target`** — Specific interactive widgets (text_link_button, inline_text_link_button, color_picker, breadcrumb_bar, difficult_cards_section, fill_submit_button) must use `SizeTokens.touchTarget`/`buttonHeight`/`inputHeight`/`listItemHeight`/`minimumSize:`/`minHeight:`

## Required — Naming & Models

**`naming_convention`** (warning) — File names must be `snake_case.dart`

**`provider_naming`** — Provider names: `^\w+RepositoryProvider$`, `^\w+UseCaseProvider$`, `^\w+ControllerProvider$`

**`freezed_json_model`** — In `features/*/domain/entities/*.dart`: must have import `freezed_annotation`, `@freezed` annotation, `part '{name}.freezed.dart'`, `part '{name}.g.dart'`, `factory Xxx.fromJson(Map<String, dynamic> json)`

## Required — Test Coverage

**`test_coverage`** — Every usecase (`domain/usecases/*.dart`) and screen (`presentation/screens/*_screen.dart`) must have a corresponding `_test.dart` in `test/features/`

## Widget Mapping — `shared_widget_mapping`

| Path | Required | Forbidden |
|---|---|---|
| `study/*_mode_screen.dart` | StudyTopBar, SessionCompleteView | AppBar(, Scaffold(appBar: |
| `folders/folder_tile.dart` | AppCardListTile(, AppTileGlyph(, AppEditDeleteMenu( | PopupMenuButton |
| `decks/deck_tile.dart` | AppCardListTile(, AppTileGlyph(, AppEditDeleteMenu( | PopupMenuButton |
| `settings/settings_stepper_row.dart` | IconActionButton( | AppCard( |
| `settings/settings_choice_row.dart` | AppPressable( | AppCard( |
| `settings/settings_action_row.dart` | AppPressable( | AppCard( |
| `cards/card_editor_view.dart` | AppCardSwitchTile( | — |
| `folders/folder_list_view.dart` | homeFolderTileDataProvider( | folderDetailProvider( |
| `*_screen.dart` (all) | — | Dismissible( |

## Performance Contracts — `performance_contract`

Specific files must contain exact tokens/patterns. Key contracts:
- `app_router.dart`: `StatefulShellRoute.indexedStack(`, `StatefulShellBranch(`
- `app_root_bottom_nav.dart`: `StatefulNavigationShell.maybeOf(context)`, `shellState.goBranch(`
- `folders_provider.dart`: all root streams must be `@Riverpod(keepAlive: true)`
- `folder_detail_provider.dart`: must use scoped providers (`folderByIdProvider(`, `subfolderProvider(`, `decksByFolderProvider(`), forbidden: `allFoldersProvider`, `allDecksProvider`, `allFlashcardsProvider`
- `deck_detail_provider.dart`: must use scoped providers (`deckByIdProvider(`, `cardsByDeckProvider(`), forbidden: `allDecksProvider`, `deckStatsProvider(`
- `app_async_builder.dart`: `this.animate = false,`
- `fade_in_widget.dart`: `this.duration = DurationTokens.fast,`

## Typography Scale — `typography_scale`

`lib/core/theme/tokens/typography_tokens.dart` must define exact scale: statDisplay=48, displayLarge/Medium=32, headlineLarge/titleLarge=24, headlineMedium=20, titleMedium/Small/bodyLarge/Medium=16, bodySmall/labelLarge=14, labelMedium/Small/caption=12. `AGENTS.md` and `docs/memox-typography-usage-rules.md` must reference the scale `48/32/24/20/16/14/12`.

## Color Palette — `color_palette`

Only allowed hex values in `lib/core/theme/tokens/color_tokens.dart`:
Seed: indigo=5C6BC0, teal=4DB6AC, rose=E57373, amber=FFB74D, slate=78909C, sage=81C784.
Semantic: success=4DB6AC/80CBC4, warning=FFB74D/FFCC80, error=E57373/EF9A9A, mastery=66BB6A/81C784.
Surface: light=FAFAFA/F5F5F5, dark=1C1C1E/2C2C2E, onSurface-light=1D1D1F/6A6A6F, onSurface-dark=E5E5E7/C2C2C8.
Status: new=9E9E9E, learning=FFB74D, reviewing=5C6BC0, mastered=4DB6AC.
Rating: again=E57373, hard=FFB74D, good=5C6BC0, easy=4DB6AC. Self-assessment: missed=E57373, partial=FFB74D, got_it=4DB6AC.

## Design Tokens — `design_token_usage`

Each class must be in its file: ColorTokens→color_tokens, TypographyTokens→typography_tokens, SpacingTokens→spacing_tokens, SizeTokens→size_tokens, RadiusTokens→radius_tokens, DurationTokens→duration_tokens, ElevationTokens→elevation_tokens, EasingTokens→easing_tokens, OpacityTokens→opacity_tokens (all in `lib/core/theme/tokens/`).

## Drift Tables — `drift_table` + `srs_field`

Required columns in `lib/core/database/tables/`:
- **folders**: id, name, parentId, colorValue, createdAt, updatedAt, sortOrder
- **decks**: id, name, folderId, colorValue, tags, createdAt, updatedAt
- **cards**: id, deckId, front, back, status, easeFactor, interval, repetitions, nextReviewDate (SRS fields)
- **study_sessions**: id, deckId, mode, startedAt, totalCards, correctCount, wrongCount
- **card_reviews**: id, cardId, sessionId, mode, isCorrect, reviewedAt

## Folder Structure — `folder_structure` + `feature_completeness`

Root: `lib/core`, `lib/shared`, `lib/features`. Core dirs: theme/{tokens,color_schemes,component_themes,text_themes}, responsive, router, constants, utils, extensions, mixins, errors, database/{tables,daos}, backup, services, providers, types. Features (folders, decks, cards, study, statistics, settings, search) each need: data/{tables,daos,mappers,repositories}, domain/{entities,repositories,usecases}, presentation/{screens,widgets,providers}.
