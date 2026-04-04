# MemoX — Development Priorities & Improvement Areas

> Living document tracking what needs to be built, fixed, and improved.
> Updated: 2026-04-05

---

## Critical Bugs

### BUG-1: Tags lost on backup restore (data loss)

`lib/core/backup/backup_service.dart` — `_cardToJson` serializes `tags` but `_cardFromJson` does not restore it. Every Drive/file restore silently drops all card tags.

**Fix**: Add `tags: Value(json['tags'] as String? ?? '')` to `_cardFromJson`'s `CardsTableCompanion` construction.

---

## Missing Features (Priority Order)

### FEAT-1: Review Mode (flip card + SRS rating)

The only unimplemented study mode. SRS engine is complete (`processReview` with Again/Hard/Good/Easy ratings exists), but there is no front-end.

**Needed**:
- `ReviewModeScreen` — flip card UI showing front → tap to reveal back → rate quality
- `review_provider.dart` — session state management, card queue, SRS calls
- Domain engine wiring to `SRSEngine.processReview()`
- Add `StudyMode.review` case in `StudyScreen.build()` dispatcher
- Use `StudyTopBar` + `SessionCompleteView` (shared widgets)
- Route: `/deck/:deckId/study/review`

**Reference**: Match/guess/recall/fill mode screens for pattern. `FlipCardWidget` in `shared/widgets/animations/` for the flip animation.

### FEAT-2: Search (full-text across folders, decks, cards)

Entire stack is scaffolded but hollow — repository returns `[]`, screen is a no-op.

**Needed**:
- `SearchDao` with Drift full-text queries across folders (name), decks (name, tags), cards (front, back)
- Typed search result entity (not `List<String>`) with result type discriminator (folder/deck/card)
- `SearchRepositoryImpl.search()` wired to DAO
- `searchQueryProvider` debounced, triggering `SearchItemsUseCase`
- Results list UI with `AppListTile` / `AppCardListTile`, navigation to matched item
- Empty state and loading state via `AppAsyncBuilder`

### FEAT-3: Google Drive Backup/Restore UI

Backend is fully implemented (`BackupService.backupToDrive/restoreFromDrive/listDriveBackups`). No UI exists.

**Needed**:
- Settings section or dedicated screen for Google Drive backup management
- Google Sign-In button with account display
- "Backup Now" action → `backupToDrive()`
- Backup list with timestamps → `listDriveBackups()`
- Restore action with confirmation dialog → `restoreFromDrive(fileId)`
- Delete old backups → `GoogleDriveService.deleteBackup()` (method exists, never called)
- `syncEnabled` toggle on `AppSettings` (field exists, not wired to UI)

### FEAT-4: Language Picker in Settings

`UpdateLocaleUseCase`, `settingsProvider.updateLocale()`, and 3 locales (EN, KO, VI) are all implemented. No UI to switch language.

**Needed**:
- Language selection row in `SettingsAppearanceSection`
- `ChoiceBottomSheet` or similar picker for locale selection
- Wire to `updateLocale()` → app rebuild with new locale

### FEAT-5: Per-Deck Statistics Drill-Down

Statistics dashboard exists but is global only. No way to view stats for a specific deck.

**Needed**:
- Route: `/deck/:deckId/statistics`
- Per-deck stats screen showing: mastery distribution, review history, session history, difficult cards
- Entry point from `DeckDetailScreen`
- Reuse existing `StatCard`, `MasteryBar`, `MasteryRing` shared widgets

### FEAT-6: Session History List

No way to view past study sessions.

**Needed**:
- Session history screen or tab within statistics
- List of sessions with: deck name, mode, date, card count, accuracy
- `StudySessionDao` already has query capabilities
- Use `AppListTile` / `AppSlidableRow` for the list

---

## Architecture Improvements

### ARCH-1: Result<T> Consistency

CRUD use cases correctly return `Result<T>`, but study and statistics use cases throw raw exceptions.

**Affected**:
- `StartStudySessionUseCase` → `Future<StudySession>` (should be `Result<StudySession>`)
- `CompleteStudySessionUseCase` → `Future<StudySession>` (same)
- `GetStudyStatsUseCase`, `GetStreakUseCase`, `GetWeeklyActivityUseCase`, `GetMasteryBreakdownUseCase`, `GetDifficultCardsUseCase` → all raw `Future<T>`
- `SearchItemsUseCase` → `Future<List<String>>`
- Settings use cases → `Future<void>` / raw types

**Impact**: Errors surface as generic async errors in `AppAsyncBuilder` instead of typed `Failure` values. Inconsistent error handling across the app.

### ARCH-2: Responsive Design Adoption

Full responsive infrastructure exists (`ScreenType`, `AdaptiveLayout`, `ResponsiveBuilder`, `ResponsiveGrid`) but **zero feature screens** use it. On tablet/desktop, content stretches full-width with no adaptation.

`ScreenType.flashcardWidth` and `ScreenType.matchColumnWidth` are defined but never consumed.

**Priority screens for responsive adoption**:
1. Study mode screens (constrain flashcard width)
2. Statistics dashboard (multi-column on tablet)
3. Home / folder detail (grid layout on expanded screens)
4. Settings (constrain max content width)

### ARCH-3: Database Migration Robustness

Schema at version 2 with minimal migration handling.

**Gaps**:
- No `onDowngrade` handler (Drift defaults to destructive migration → data loss)
- No schema integrity validation in `beforeOpen`
- No migration tests
- Single `if (from < 2)` block with no chain prepared for future versions

### ARCH-4: Backup Validation

`importFromJson` performs full DB wipe before inserting restored data. If insertion fails mid-transaction, Drift rolls back, but the DB is already empty.

**Improvements needed**:
- Pre-validate all records before deletion
- Backup version migration: handle missing/renamed fields gracefully instead of `as String` casts that throw
- Auto-prune old Drive backups (method exists, never called)

---

## Code Cleanup

### CLEAN-1: Dead Code

| File | Issue |
|------|-------|
| `lib/core/constants/app_strings.dart` | ~80 hardcoded strings duplicating L10n. Never imported. Delete. |
| `lib/core/network/` (empty tree) | `api/`, `dto/`, `interceptors/` — all empty. Leftover from Isar/Retrofit era. Delete. |
| 14 empty `*FeatureDaos`/`*FeatureTables` stubs | `abstract final class XFeatureDaos { const XFeatureDaos._(); }` with no members, never imported. Either convert to barrel exports or delete. |

### CLEAN-2: Placeholder Screens

| Screen | Status |
|--------|--------|
| `decks_screen.dart` (19 lines) | Shows `DecksPlaceholderView` — scaffold-era stub. Deck browsing works through folder hierarchy, but this bottom nav tab destination shows nothing. |
| `cards_screen.dart` (17 lines) | Shows `CardsPlaceholderView` — same issue. |
| `search_screen.dart` (28 lines) | Non-functional stub (see FEAT-2). |

### CLEAN-3: Stale L10n Strings

All 3 locale files contain scaffold-era copy like `"foldersSubtitle": "Folder feature scaffold is ready for implementation."` that is user-visible. Review and update to meaningful descriptions.

---

## Test Coverage Gaps

### Priority 1: Data Layer (zero tests across 6/7 features)

No feature except `settings` has data-layer tests. Repositories, datasources, and mappers are completely untested.

**Start with**: Folder and deck repositories (most used paths), card repository (SRS queries).

### Priority 2: Study Providers

Only `fill`, `guess`, `match`, `recall` providers have tests. Missing:
- Session lifecycle testing (start → study → complete)
- SRS integration tests (review → interval update → next due date)
- Edge cases: empty deck, all cards mastered, session interruption

### Priority 3: Statistics Presentation

13 statistics widget files with zero tests. The dashboard is complex with charts, date range filters, and multiple data dependencies.

### Priority 4: Core Services

Zero tests for:
- `core/backup/` — backup/restore cycle
- `core/services/` — all 10 service files
- `core/router/` — navigation integration
- 9 of 10 extension files
- 5 of 7 mixin files

### Priority 5: Shared Widgets

59 of 75 shared widget files lack dedicated tests. Key untested widgets:
- All 7 animation widgets (flip card, shake, pulse, stagger, fade, count up, scale tap)
- All 5 dialog widgets
- Core buttons: `PrimaryButton`, `SecondaryButton`, `AppFab`, `IconActionButton`
- All card variants: `AppCard`, `SelectableCard`, `StatCard`, `InfoBar`
- All input widgets: `AppTextField`, `StepperInput`, `TagInputField`
- `AppAsyncBuilder`, `Toast`, `LoadingOverlay`

---

## Guard Tool

### GUARD-1: Typography Scale Guard — False Positive

The `typography_scale` guard checks for `docs/memox-typography-usage-rules.md` which was consolidated into `docs/memox-reference.md`. Update the guard's expected file path in `project_rules.yaml` or the guard implementation.

---

## Development Order Recommendation

```
1. BUG-1   — Tags backup restore fix (5 min, critical data loss)
2. GUARD-1 — Fix typography guard false positive (5 min)
3. CLEAN-1 — Delete dead code (10 min)
4. FEAT-1  — Review mode (high value, SRS engine ready)
5. FEAT-2  — Search (core UX feature)
6. FEAT-4  — Language picker (quick win, backend ready)
7. FEAT-3  — Google Drive backup UI (backend ready)
8. ARCH-1  — Result<T> consistency (code quality)
9. FEAT-5  — Per-deck statistics
10. FEAT-6 — Session history
11. ARCH-2 — Responsive design adoption
12. ARCH-3 — Migration robustness
13. ARCH-4 — Backup validation
14. Test coverage (ongoing, prioritize by coverage gaps above)
```
