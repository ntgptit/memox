## 1. Issues fixed

- Direct `StudyScreen(deckId, mode)` entry now refuses invalid starts before entering a mode screen.
  - Fixed outcomes: `nothing to study` and `container missing`.
  - Evidence: `lib/features/study/presentation/providers/study_entry_provider.dart`, `lib/features/study/presentation/screens/study_screen.dart`.
- Recommendation UI no longer overstates `modePlan` as an executable multi-mode runtime.
  - Fixed outcomes: CTA now means “Start with {mode}”; mode chips are labeled as recommended modes, not guaranteed runtime flow.
  - Evidence: `lib/features/study/presentation/widgets/study_recommendation_card.dart`, `l10n/app_en.arb`, `l10n/app_vi.arb`, `l10n/app_ko.arb`.
- Resume UI now describes resuming the current mode, not a full docs-defined multi-mode session.
  - Evidence: `lib/features/study/presentation/widgets/study_active_session_card.dart`, `lib/features/study/presentation/screens/study_screen.dart`, `l10n/app_*.arb`.
- Recall now keeps missed cards inside the same recall run until retry handling is resolved.
  - Fixed outcomes: first miss becomes retry-pending; retry success replaces the earlier miss; second miss finalizes the card as missed and allows completion.
  - Evidence: `lib/features/study/presentation/providers/recall_provider.dart`, `lib/features/study/presentation/screens/recall_mode_screen.dart`.
- Match now continues across grouped boards instead of ending after the first capped board.
  - Fixed outcomes: cumulative progress, grouped-board resume state, and final completion only after the last board.
  - Evidence: `lib/features/study/domain/match/match_engine.dart`, `lib/features/study/presentation/providers/match_provider.dart`, `lib/features/study/presentation/factories/study_mode_flow_factory.dart`.
- Fill no longer opens a post-completion `practice mistakes` sub-run that was not grounded in the study docs.
  - Fixed outcome: retry/remediation stays inside the main fill run; completion view no longer exposes a separate practice-only loop.
  - Evidence: `lib/features/study/presentation/providers/fill_provider.dart`, `lib/features/study/presentation/screens/fill_mode_screen.dart`.

## 2. Files changed

- Source
  - `l10n/app_en.arb`
  - `l10n/app_vi.arb`
  - `l10n/app_ko.arb`
  - `lib/features/study/domain/match/match_engine.dart`
  - `lib/features/study/presentation/factories/study_mode_flow_factory.dart`
  - `lib/features/study/presentation/providers/fill_provider.dart`
  - `lib/features/study/presentation/providers/match_provider.dart`
  - `lib/features/study/presentation/providers/recall_provider.dart`
  - `lib/features/study/presentation/providers/study_entry_provider.dart`
  - `lib/features/study/presentation/screens/fill_mode_screen.dart`
  - `lib/features/study/presentation/screens/recall_mode_screen.dart`
  - `lib/features/study/presentation/screens/study_screen.dart`
  - `lib/features/study/presentation/widgets/study_active_session_card.dart`
  - `lib/features/study/presentation/widgets/study_recommendation_card.dart`
- Generated
  - `lib/features/study/presentation/providers/match_provider.freezed.dart`
  - `lib/features/study/presentation/providers/match_provider.g.dart`
  - `lib/features/study/presentation/providers/recall_provider.freezed.dart`
  - `lib/features/study/presentation/providers/recall_provider.g.dart`
  - `lib/features/study/presentation/providers/study_entry_provider.g.dart`
- Tests
  - `test/features/study/presentation/providers/match_provider_test.dart`
  - `test/features/study/presentation/providers/recall_provider_test.dart`
  - `test/features/study/presentation/providers/study_entry_provider_test.dart`
  - `test/features/study/presentation/screens/fill_mode_screen_test.dart`
  - `test/features/study/presentation/screens/match_mode_screen_test.dart`
  - `test/features/study/presentation/screens/recall_mode_screen_test.dart`
  - `test/features/study/presentation/screens/study_screen_test.dart`

## 3. Tests added or updated

- Added direct provider coverage for study entry gating.
  - `test/features/study/presentation/providers/study_entry_provider_test.dart`
  - Covered cases: non-review empty deck refusal, matching saved snapshot bypassing eligibility refusal.
- Expanded recall provider coverage.
  - `test/features/study/presentation/providers/recall_provider_test.dart`
  - Covered cases: in-session retry pending, retry success replacing a prior miss, second miss finalizing the card as missed, retry state surviving restore.
- Expanded match provider coverage.
  - `test/features/study/presentation/providers/match_provider_test.dart`
  - Covered cases: grouped-board continuation and grouped-board progress surviving restore.
- Expanded screen coverage.
  - `test/features/study/presentation/screens/study_screen_test.dart`
    - honest recommendation CTA copy
    - explicit refusal for missing deck and nothing-due review entry
    - current-mode resume wording
  - `test/features/study/presentation/screens/recall_mode_screen_test.dart`
    - recall no longer jumps into the old post-completion practice path
  - `test/features/study/presentation/screens/match_mode_screen_test.dart`
    - grouped board continuation
    - eventual completion after the final grouped board
  - `test/features/study/presentation/screens/fill_mode_screen_test.dart`
    - completion after retry remediation without a `practice mistakes` action

## 4. Remaining ambiguities

- The docs still do not define a universal retry ceiling.
  - Chosen interpretation in code: recall gives one in-session retry opportunity; a second miss finalizes the card as missed.
- The docs describe `modePlan` as runtime session flow, but the current runtime remains mode-first.
  - Chosen interpretation in this pass: the hub presents `modePlan` as recommendation metadata only.
- The docs mention timeout and unauthorized branches, but the feature still lacks a concrete local access contract and a concrete timeout policy.
  - This pass did not invent those policies.

## 5. Deferred items

- Full docs-defined session aggregate and generic snapshot contract.
  - Still missing: `sessionType`, `modePlan`, `activeMode`, `currentItem`, generic `progress`, `sessionCompleted`, `allowedActions`.
- Real multi-mode execution across the documented `modePlan`.
  - The feature still starts one mode directly and completes per mode.
- Moving long-term learning-state updates to a session-completion boundary.
  - Providers still perform per-attempt SRS writes.
- Analytics/reporting contract from the study docs.
  - No session-level analytics emission was added in this pass.
- Unauthorized/access-denied enforcement through a real domain or repository contract.
  - Entry gating now handles missing deck and empty eligibility only.

## 6. Risk notes

- The feature is materially closer to the study docs than before this remediation, but it is still mode-first rather than the full session-engine architecture described by the markdown.
- Recall retry and hub `modePlan` behavior now follow explicit safe interpretations of ambiguous docs. If product chooses a different retry ceiling or real multi-mode runtime later, these paths will need another contract pass.
- Verification completed on the final state of this pass:
  - `flutter test test/features/study` passed.
  - `flutter test test/features/study/presentation/providers/study_entry_provider_test.dart` passed.
  - `python tools/guard/run.py --scope features` passed with the same 14 pre-existing `feature_completeness` warnings for empty feature subfolders.
  - `flutter analyze` now reports only one pre-existing `info` outside study scope at `lib/features/statistics/presentation/widgets/statistics_period_tabs.dart:62`.
- Tooling note:
  - Running multiple `flutter test` commands in parallel on Windows hit a Flutter tool crash around `NativeAssetsManifest.json`. Sequential reruns passed; this did not indicate a study-feature regression.
