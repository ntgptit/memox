## 1. Fixes applied

- Fixed the remaining review-mode retry visibility gap called out in `lib/features/study/docs/review/study-ui-and-state-flow-review.md:189`. `ReviewRoundView` now shows a retry-phase `InfoBar` when the current card is retry-pending, using the existing `ReviewState.isCurrentCardPendingRetry` signal in `lib/features/study/presentation/widgets/review_round_view.dart:50-59`.
- Closed the hub async-error test gap called out in `lib/features/study/docs/review/study-scenario-and-test-gap-analysis.md:90,152`. `StudyScreen` already rendered hub errors through `AppAsyncBuilder`; this pass added explicit regression coverage for that user-visible state in `test/features/study/presentation/screens/study_screen_test.dart:124-144`.
- Added regression coverage for the review retry-round flow so the new UI cue is locked to the documented retry behavior from `lib/features/study/docs/03_session_lifecycle.md:49-60` and `lib/features/study/docs/05_execution_rules.md:56-64`. Covered in `test/features/study/presentation/screens/review_mode_screen_test.dart:317-356`.

## 2. Files changed

- `lib/features/study/presentation/widgets/review_round_view.dart`
- `test/features/study/presentation/screens/review_mode_screen_test.dart`
- `test/features/study/presentation/screens/study_screen_test.dart`
- `lib/features/study/docs/review/study-final-fix-and-verification-summary.md`

## 3. Tests added or updated

- Added `ReviewModeScreen shows a retry hint when a failed card returns` in `test/features/study/presentation/screens/review_mode_screen_test.dart:317-356`.
- Added `study screen shows hub async errors` in `test/features/study/presentation/screens/study_screen_test.dart:124-144`.
- Re-ran the full study feature test suite after the changes to confirm the previously fixed flows still hold: direct-entry loading/error/retry, start-over gating, guess retry cue, recall retry cue, and match grouped-board progress.

## 4. Verification results

- `flutter test test/features/study/presentation/screens/review_mode_screen_test.dart` passed.
- `flutter test test/features/study/presentation/screens/study_screen_test.dart` passed.
- `flutter test test/features/study` passed.
- `python tools/guard/run.py --scope features` passed with only pre-existing feature-structure warnings outside this task’s change scope.
- `flutter analyze` reported one pre-existing `info` outside the study feature at `lib/features/statistics/presentation/widgets/statistics_period_tabs.dart:62`.
- Final self-verification against the docs and review files:
  - Retry-phase visibility is now materially aligned for review, guess, and recall mode UI.
  - Grouped-board progress remains aligned with the previously fixed match UI.
  - Hub loading/error rendering is now explicitly covered by tests.
  - Direct-entry loading, refusal, retry, resume, and start-over flows remain covered and passing.

## 5. Remaining mismatches

- The docs-defined generic session aggregate is still absent: no `sessionType`, `modePlan`, `currentMode`, `allowedActions`, or session-level item snapshot contract as described in `lib/features/study/docs/review/study-compliance-checklist.md:21-38,121-127`.
- The feature still completes each mode independently instead of only completing after the final mode in a docs-level session plan. This remains confirmed in `lib/features/study/docs/review/study-ui-and-state-flow-review.md:201`.
- Unauthorized / no-access start refusal is still not implemented. The gap remains confirmed in `lib/features/study/docs/review/study-compliance-checklist.md:179-189` and `lib/features/study/docs/review/study-scenario-and-test-gap-analysis.md:58,122`.
- Guess and recall timeout-driven flows remain unimplemented, as noted in `lib/features/study/docs/review/study-compliance-checklist.md:197-201` and `lib/features/study/docs/review/study-scenario-and-test-gap-analysis.md:117-118`.
- Match still does not implement a docs-level board fail/retry threshold; only grouped-board progress is surfaced. This remains confirmed in `lib/features/study/docs/review/study-ui-and-state-flow-review.md:193,200`.
- Invalid-action and invalid-payload handling are still implicit silent guards rather than an explicit rejection contract, matching the open finding in `lib/features/study/docs/review/study-ui-and-state-flow-review.md:205`.

## 6. Deferred items

- Session-contract rewrite work was deferred: introducing a generic study session model, `modePlan`, `allowedActions`, session-level persistence, and final-mode-only completion would be a broader architecture change, not a minimal remediation.
- Unauthorized/no-access UI was deferred because the current entry contract only exposes `ready`, `nothingToStudy`, and `containerNotFound` in `lib/features/study/presentation/providers/study_entry_provider.dart`; there is still no grounded access-denied signal to render.
- Timeout behavior was deferred because the docs mention it, but the review set does not provide a safe, implementation-ready policy for exact timeout duration, grading effect, or reveal penalty.
- Match board fail/retry semantics were deferred because the docs describe the idea, but do not define an explicit failure threshold or retry policy that can be implemented safely without inventing behavior.
- Analytics/reporting contract changes were deferred because the current reviews still classify them as part of the missing session aggregate rather than a small isolated fix.

## 7. Confidence notes

- High confidence that the user-visible retry flow is materially closer to the reviewed docs after this pass. The remaining visible retry-gap in review mode is now closed in code and backed by a widget test.
- High confidence that the hub async error surface is now verified, not just assumed, because the screen test covers the exact `AppAsyncBuilder` error branch.
- Medium confidence on overall docs compliance. The remaining open items are not small polish gaps; they are architectural or contract-level deviations already identified by the existing review reports.
- The final verification statements above are grounded in the current code, the current test suite run, and the existing review documents rather than new speculation.
