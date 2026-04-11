## 1. UI mismatches fixed

- Added a visible retry-phase hint to guess rounds so retry-pending cards are no longer silently reintroduced. Implemented in `lib/features/study/presentation/widgets/guess_round_view.dart:39-44` using `context.l10n.studyRetryPhaseHint`.
- Added a visible retry-phase hint to recall rounds so a second-pass card is explicitly marked before completion. Implemented in `lib/features/study/presentation/widgets/recall_round_view.dart:74-80` using the same localized message.
- Added visible grouped-board progress for match mode so multi-board sessions no longer look like one undifferentiated board. Implemented in `lib/features/study/presentation/widgets/match_round_view.dart:37-43` using `context.l10n.matchBoardProgressLabel(...)`.
- Added localized copy for the new study retry and board-progress surfaces in `l10n/app_en.arb:135-137`, `l10n/app_vi.arb:135-137`, and `l10n/app_ko.arb:135-137`.

## 2. State-flow mismatches fixed

- Direct-entry loading is now regression-covered, matching the documented requirement that async session entry exposes loading before the requested mode opens. Covered by `test/features/study/presentation/screens/study_screen_test.dart:124-156`.
- Direct-entry async failure plus retry is now regression-covered, including recovery into the requested mode after retry. Covered by `test/features/study/presentation/screens/study_screen_test.dart:160-208`.
- Route-level `Start over` is now regression-covered to ensure snapshot bypass is cleared and entry gating runs again instead of silently resuming. Covered by `test/features/study/presentation/screens/study_screen_test.dart:356-414`.
- Recall retry flow is now regression-covered so first miss enters visible retry state and second miss completes only after that retry pass. Covered by `test/features/study/presentation/screens/recall_mode_screen_test.dart:121-160`.
- Match grouped-board progression is now regression-covered at the UI layer so board advancement is visible across boards. Covered by `test/features/study/presentation/screens/match_mode_screen_test.dart:170-206`.

## 3. User-visible behavior changes

- Guess mode now tells the learner when they are in a retry round instead of silently cycling a failed card back in.
- Recall mode now tells the learner when they are revisiting a missed card before the final completion step.
- Match mode now shows explicit board progress such as `Board 1 of 2` and `Board 2 of 2` during multi-board sessions.
- Study screen retry behavior for direct entry is now protected so loading, error, retry, and restart paths stay aligned with the reviewed docs.

## 4. Tests added or updated

- Added `study screen shows a loading indicator while direct entry is resolving` in `test/features/study/presentation/screens/study_screen_test.dart:124-156`.
- Added `study screen retries a failed direct entry resolution and then opens the mode` in `test/features/study/presentation/screens/study_screen_test.dart:160-208`.
- Added `study screen start over re-runs entry gating after a snapshot bypass` in `test/features/study/presentation/screens/study_screen_test.dart:356-414`.
- Added `GuessModeScreen shows a retry hint when a card returns` in `test/features/study/presentation/screens/guess_mode_screen_test.dart:287-333`.
- Added `RecallModeScreen shows a retry hint before completing after a second miss` in `test/features/study/presentation/screens/recall_mode_screen_test.dart:121-160`.
- Updated the grouped-board UI assertion flow in `test/features/study/presentation/screens/match_mode_screen_test.dart:170-206` to verify `Board 1 of 2` and `Board 2 of 2`.

## 5. Remaining gaps

- Unauthorized or no-access state is still missing. The review identified it, but the current entry model only exposes `ready`, `nothingToStudy`, and `containerNotFound`, so there is no grounded access-denied signal to render yet.
- The feature still executes one requested mode at a time instead of the docs-level `mode plan` lifecycle. Fixing that would require a broader session coordinator change outside this safe UI/state pass.
- Generic `RESET_CURRENT_MODE` still exists only as route-level `Start over`; it is not implemented as a normalized study state action across active mode screens.
- Guess and recall timeout-driven alternatives from the docs are still not implemented. The review marked these as documented flows, but the current code and review files do not provide a safe, unambiguous product policy for timeout handling.
- Match still does not expose a docs-style board-level fail/retry state; this pass only surfaced grouped-board progress that already existed in provider state.

## 6. Risk notes

- This pass intentionally stayed inside documented, user-visible UI/state mismatches that were already grounded in the review files and existing provider state.
- No session-engine rewrite, architecture rewrite, or cross-feature redesign was attempted.
- Verification after the fixes:
  - `flutter test test/features/study` passed.
  - `python tools/guard/run.py --scope features` passed with only pre-existing feature-structure warnings outside this change scope.
  - `flutter analyze` still reports one pre-existing info in `lib/features/statistics/presentation/widgets/statistics_period_tabs.dart:62`, outside the study feature scope touched here.
