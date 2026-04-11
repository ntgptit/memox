# 1. Iteration count

- Total iterations executed in this recursive pass: `3`

# 2. Fixes applied in each iteration

## Iteration 1

- Added a visible retry-phase hint to review mode when a failed card returns in the same session.
- Added regression coverage for the study hub async error branch.
- Added regression coverage for the review retry-round surface.

## Iteration 2

- Added a visible retry-phase hint to fill mode when the learner enters retry/remediation after a wrong answer.
- Updated fill-mode widget coverage so the retry state is asserted explicitly.

## Iteration 3

- Added regression coverage for the study hub loading state.
- Re-ran full study verification and rescanned the remaining review findings against the current code.

# 3. Files changed in each iteration

## Iteration 1

- `lib/features/study/presentation/widgets/review_round_view.dart`
- `test/features/study/presentation/screens/review_mode_screen_test.dart`
- `test/features/study/presentation/screens/study_screen_test.dart`

## Iteration 2

- `lib/features/study/presentation/widgets/fill_round_view.dart`
- `test/features/study/presentation/screens/fill_mode_screen_test.dart`

## Iteration 3

- `test/features/study/presentation/screens/study_screen_test.dart`

# 4. Tests added or updated in each iteration

## Iteration 1

- Added `ReviewModeScreen shows a retry hint when a failed card returns` in `test/features/study/presentation/screens/review_mode_screen_test.dart`.
- Added `study screen shows hub async errors` in `test/features/study/presentation/screens/study_screen_test.dart`.

## Iteration 2

- Updated `FillModeScreen shows hint and skip after the first wrong answer` in `test/features/study/presentation/screens/fill_mode_screen_test.dart` to assert the retry-round hint.

## Iteration 3

- Added `study screen shows hub loading state` in `test/features/study/presentation/screens/study_screen_test.dart`.

# 5. Verification result after each iteration

## Iteration 1

- `dart format` passed for changed files.
- `flutter test test/features/study/presentation/screens/review_mode_screen_test.dart` passed.
- `flutter test test/features/study/presentation/screens/study_screen_test.dart` passed.
- Remaining safe issues found after rescan:
  - Fill mode still entered retry state without an explicit retry-round cue.
  - Study hub loading state was still untested.

## Iteration 2

- `dart format` passed for changed files.
- `flutter test test/features/study/presentation/screens/fill_mode_screen_test.dart` initially failed due a missing `context_extensions.dart` import in `fill_round_view.dart`; that compile issue was fixed immediately in the same iteration.
- `flutter test test/features/study/presentation/screens/fill_mode_screen_test.dart` then passed.
- Remaining safe issues found after rescan:
  - Study hub loading state was still untested.

## Iteration 3

- `dart format` passed for changed files.
- `flutter test test/features/study/presentation/screens/study_screen_test.dart` passed.
- `flutter test test/features/study` passed.
- `python tools/guard/run.py --scope features` passed with only pre-existing feature-structure warnings outside this task scope.
- `flutter analyze` reported one pre-existing `info` outside the study scope at `lib/features/statistics/presentation/widgets/statistics_period_tabs.dart:62`.
- Final rescan result:
  - No remaining confirmed reviewed mismatch inside `lib/features/study` was found to be safely fixable without crossing into a larger contract or architecture rewrite.

# 6. Remaining issues found after each iteration

## After Iteration 1

- Fill retry/remediation state still lacked the same visible retry-round cue now shown in guess, review, and recall.
- Hub loading state still lacked explicit regression coverage.

## After Iteration 2

- Hub loading state still lacked explicit regression coverage.

## After Iteration 3

- No additional safe in-scope issue remained after rechecking docs, review findings, changed flows, and changed tests.

# 7. Deferred items

- Generic study-session aggregate and snapshot contract: `sessionType`, `modePlan`, `activeMode`, `allowedActions`, `currentItem`, `progress`, and `sessionCompleted`.
- Multi-mode runtime execution of `modePlan` instead of launching one mode at a time.
- Unauthorized / no-access start refusal.
- Explicit invalid-action and invalid-payload rejection contract.
- Timeout-based guess behavior.
- Timeout reveal / reveal-penalty behavior in recall.
- Match board-level fail/retry semantics beyond grouped-board progression.
- Session-level analytics and reporting contract.
- Session-level completion semantics where long-term learning-state updates happen only after final-mode completion.

# 8. Reason each deferred item was not safely fixable

- Generic session aggregate / snapshot contract:
  - The existing implementation is mode-first across providers, persistence, restore payloads, and tests. Replacing it with the docs-defined aggregate would be a broad feature contract rewrite, not a minimal safe fix.
- Multi-mode `modePlan` execution:
  - The hub already computes and displays a plan, but runtime execution is still single-mode. Converting that into a real session coordinator would require cross-provider orchestration and new persistence semantics.
- Unauthorized / no-access start refusal:
  - The current entry contract only exposes `ready`, `nothingToStudy`, and `containerNotFound` in `study_entry_provider.dart`. There is no grounded access-denied signal to render without inventing behavior.
- Invalid-action / invalid-payload rejection contract:
  - Current providers use silent guard returns. Introducing a shared failure contract would change state shapes, action APIs, and test expectations across all modes.
- Guess timeout and recall timeout / reveal penalty:
  - The docs mention these flows, but the reviewed docs and current implementation do not define a safe concrete policy for duration, grading impact, or retry interaction.
- Match board-level fail/retry semantics:
  - Grouped-board progression is implemented, but the docs do not define a failure threshold or board retry policy precise enough for a safe minimal patch.
- Analytics and session-level completion rules:
  - These depend on the missing session aggregate and multi-mode lifecycle. Adding them in isolation would create more drift, not less.

# 9. Final alignment status with docs

- Materially improved and now aligned for the safe UI/state issues confirmed by the review set:
  - Retry-round visibility exists in all retry-capable study surfaces that already expose retry state in code: guess, review, recall, and fill.
  - Grouped-board progress is visible in match mode.
  - Study entry and hub loading/error paths are regression-covered.
  - Direct-entry refusal, retry, resume, and route-level start-over flows remain verified.
- Still not aligned on the larger deferred contracts:
  - docs-defined generic session aggregate
  - `modePlan` runtime execution
  - explicit `allowedActions`
  - unauthorized access flow
  - timeout contracts
  - session-level completion / analytics contracts
- Final conclusion:
  - After the recursive fix/verify/re-scan loop, no remaining issue inside `lib/features/study` was found to be both confirmed by the docs/reviews and safely fixable without a larger structural redesign.
