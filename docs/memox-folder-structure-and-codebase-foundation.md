# 📁 MemoX — Folder Structure & Codebase Foundation

> **Mục đích**: Định nghĩa toàn bộ kiến trúc codebase, design tokens,
> theme system, shared widgets, utils, và mọi thành phần nền tảng
> cần có TRƯỚC khi implement features.
>
> **Tài liệu này là "source of truth"** — mọi prompt phát triển sau
> phải tuân thủ cấu trúc và naming conventions ở đây.

---

## 📂 FOLDER STRUCTURE TOÀN BỘ

```
lib/
│
├── main.dart                          # Entry point, ProviderScope, runApp
├── app.dart                           # MaterialApp.router, theme binding
│
├── core/                              # ━━━ Foundation layer (feature-agnostic) ━━━
│   │
│   ├── theme/                         # ── M3 Design Token System ──
│   │   ├── tokens/
│   │   │   ├── color_tokens.dart      # Semantic color roles (M3 color scheme)
│   │   │   ├── typography_tokens.dart  # Type scale: display, headline, title, body, label
│   │   │   ├── spacing_tokens.dart    # 4dp grid: xs(4), sm(8), md(12), lg(16), xl(24), xxl(32)
│   │   │   ├── size_tokens.dart      # Component dimensions: icon, avatar, button, input, nav heights
│   │   │   ├── radius_tokens.dart     # Corner radius: xs(4), sm(8), md(12), lg(16), xl(28), full(100)
│   │   │   ├── elevation_tokens.dart  # M3 tonal elevation: level0-5
│   │   │   ├── duration_tokens.dart   # Motion: fast(100ms), normal(200ms), slow(300ms), slower(500ms)
│   │   │   ├── easing_tokens.dart     # M3 easing curves: emphasized, standard, decelerated
│   │   │   └── opacity_tokens.dart    # State layers: hover(0.08), focus(0.12), press(0.12), drag(0.16), disabled(0.38)
│   │   │
│   │   ├── color_schemes/
│   │   │   ├── app_color_scheme.dart  # ColorScheme.fromSeed() light & dark
│   │   │   └── custom_colors.dart     # ThemeExtension<CustomColors>: success, warning, mastery, etc.
│   │   │
│   │   ├── component_themes/
│   │   │   ├── app_bar_theme.dart
│   │   │   ├── button_themes.dart     # Elevated, Filled, FilledTonal, Outlined, Text, Icon, FAB
│   │   │   ├── card_theme.dart
│   │   │   ├── chip_theme.dart
│   │   │   ├── dialog_theme.dart
│   │   │   ├── input_theme.dart       # TextField, SearchBar decoration
│   │   │   ├── navigation_bar_theme.dart
│   │   │   ├── bottom_sheet_theme.dart
│   │   │   ├── snackbar_theme.dart
│   │   │   ├── switch_theme.dart
│   │   │   ├── slider_theme.dart
│   │   │   ├── progress_indicator_theme.dart
│   │   │   ├── divider_theme.dart
│   │   │   ├── list_tile_theme.dart
│   │   │   └── segmented_button_theme.dart
│   │   │
│   │   ├── text_themes/
│   │   │   ├── app_text_theme.dart    # GoogleFonts.plusJakartaSans based TextTheme
│   │   │   └── custom_text_styles.dart # ThemeExtension<AppTextStyles>: flashcard, stat, section
│   │   │
│   │   └── app_theme.dart             # Final ThemeData assembly: light() & dark()
│   │
│   ├── design/                        # ── Design System Utilities ──
│   │   ├── app_icons.dart             # Icon constants (outlined only, consistent)
│   │   ├── app_illustrations.dart     # SVG/icon references cho empty states
│   │   └── app_shadows.dart           # Custom BoxShadow presets (very subtle, max 8% opacity)
│   │
│   ├── responsive/                    # ── Responsive & Adaptive ──
│   │   ├── breakpoints.dart           # compact(<600), medium(600-840), expanded(>840)
│   │   ├── responsive_builder.dart    # Builder widget: child builder per breakpoint
│   │   ├── responsive_padding.dart    # EdgeInsets that adapt to screen width
│   │   ├── responsive_grid.dart       # Adaptive column count (1/2/3/4 based on width)
│   │   └── screen_type.dart           # Enum + extension: ScreenType.of(context)
│   │
│   ├── router/                        # ── Navigation ──
│   │   ├── app_router.dart            # GoRouter config, StatefulShellRoute for tabs
│   │   ├── route_names.dart           # Static const route paths + param names
│   │   ├── route_transitions.dart     # Custom page transitions: slide, fade, fadeUp
│   │   └── route_guards.dart          # Redirect logic (e.g., deck exists check)
│   │
│   ├── constants/                     # ── Static Values ──
│   │   ├── app_strings.dart           # All user-facing strings (prep for i18n)
│   │   ├── app_defaults.dart          # Default values: dailyGoal, sessionLimit, srs params
│   │   ├── db_constants.dart          # DB name, version, collection names
│   │   └── app_config.dart            # Feature flags, max folder depth, etc.
│   │
│   ├── utils/                         # ── Pure Utility Functions ──
│   │   ├── date_utils.dart            # Relative time ("2 hours ago"), streak calc helpers
│   │   ├── string_utils.dart          # Truncate, capitalize, slug, fuzzy normalize
│   │   ├── color_utils.dart           # Pastel generator, contrast checker, int↔Color
│   │   ├── number_utils.dart          # Percentage format, compact number (1.2K), clamp
│   │   ├── duration_utils.dart        # Format seconds → "12:34", readable duration
│   │   ├── file_utils.dart            # JSON export/import helpers
│   │   ├── debouncer.dart             # Reusable debounce utility class
│   │   ├── throttler.dart             # Reusable throttle utility class
│   │   └── validators.dart            # Input validation: notEmpty, maxLength, unique name
│   │
│   ├── extensions/                    # ── Dart/Flutter Extensions ──
│   │   ├── context_extensions.dart    # context.theme, context.colors, context.textTheme, 
│   │   │                              # context.customColors, context.screenType, 
│   │   │                              # context.showSnackBar(), context.showBottomSheet()
│   │   ├── theme_extensions.dart      # ThemeData.customColors getter shortcut
│   │   ├── color_extensions.dart      # Color.withValues(), Color.pastel(), Color.onColor()
│   │   ├── datetime_extensions.dart   # isToday, isYesterday, startOfDay, daysBetween, 
│   │   │                              # relativeString, isSameDay
│   │   ├── string_extensions.dart     # capitalize, truncate(maxLength), initials, isBlank
│   │   ├── list_extensions.dart       # shuffled, chunked(size), safeFirst, safeElementAt
│   │   ├── num_extensions.dart        # toPercentString, toDurationString, dp (responsive)
│   │   ├── widget_extensions.dart     # paddingAll, paddingSymmetric, sliverBox, centered
│   │   ├── duration_extensions.dart   # readable ("2h 15m"), components
│   │   └── iterable_extensions.dart   # groupBy, distinctBy, sortedBy, sumBy
│   │
│   ├── mixins/                        # ── Reusable Behavior Mixins ──
│   │   ├── loading_mixin.dart         # isLoading, error, setLoading(), setError(), guard()
│   │   ├── form_validation_mixin.dart # validate(), fieldErrors, touched, markTouched()
│   │   ├── auto_dispose_mixin.dart    # Safe timer/stream disposal for StatefulWidgets
│   │   ├── scroll_mixin.dart          # scrollController, scrollToTop, isAtBottom, onScrollEnd
│   │   ├── keyboard_mixin.dart        # hideKeyboard, isKeyboardVisible
│   │   ├── haptic_mixin.dart          # lightImpact, mediumImpact, selectionClick
│   │   └── after_layout_mixin.dart    # afterFirstLayout() callback
│   │
│   ├── errors/                        # ── Error Handling ──
│   │   ├── app_exception.dart         # Sealed class: NotFound, Conflict, Validation, Storage
│   │   ├── error_handler.dart         # Global error handler, logging
│   │   └── failure.dart               # Failure record for use case results
│   │
│   ├── database/                      # ── Database Setup ──
│   │   ├── isar_provider.dart         # Riverpod provider for Isar instance
│   │   ├── db_initializer.dart        # Open DB, register schemas, seed if needed
│   │   └── migration_handler.dart     # Schema version checks, data migration logic
│   │
│   └── services/                      # ── Platform Services ──
│       ├── notification_service.dart  # flutter_local_notifications wrapper
│       ├── share_service.dart         # Share sheet (export JSON/CSV)
│       ├── file_picker_service.dart   # Import file picker wrapper
│       └── haptic_service.dart        # HapticFeedback wrapper for testability
│
├── shared/                            # ━━━ Shared Widgets & Components ━━━
│   │
│   ├── widgets/                       # ── Reusable UI Components ──
│   │   │
│   │   ├── layout/
│   │   │   ├── app_scaffold.dart      # Base scaffold: handles safe area, padding, FAB slot
│   │   │   ├── section_container.dart # Consistent section with title + optional action
│   │   │   ├── adaptive_layout.dart   # Responsive: single/two-pane based on breakpoint
│   │   │   ├── sliver_scaffold.dart   # CustomScrollView based scaffold for collapsing headers
│   │   │   └── spacing.dart           # Gap.xs, Gap.sm, Gap.md, Gap.lg — SizedBox wrappers
│   │   │
│   │   ├── feedback/
│   │   │   ├── app_async_builder.dart # AsyncValue → loading/error/data pattern (CRITICAL)
│   │   │   ├── loading_indicator.dart # Centered CircularProgressIndicator (M3 style)
│   │   │   ├── loading_overlay.dart   # Semi-transparent overlay with spinner
│   │   │   ├── error_view.dart        # Error icon + message + retry button
│   │   │   ├── empty_state_view.dart  # Icon + title + subtitle + optional CTA (reusable)
│   │   │   ├── success_indicator.dart # Animated checkmark circle
│   │   │   ├── session_complete_view.dart # Shared across all 5 study modes
│   │   │   └── toast.dart             # Lightweight snackbar wrapper (success/error/info)
│   │   │
│   │   ├── buttons/
│   │   │   ├── primary_button.dart    # Full-width filled button, loading state, disabled state
│   │   │   ├── secondary_button.dart  # Outlined variant
│   │   │   ├── text_link_button.dart  # Minimal text button for "Show more →" style actions
│   │   │   ├── icon_action_button.dart# Icon button with tooltip + press feedback
│   │   │   └── app_fab.dart           # Standardized FAB with icon + optional label
│   │   │
│   │   ├── inputs/
│   │   │   ├── app_text_field.dart    # M3 outlined text field with label, hint, error, counter
│   │   │   ├── app_search_bar.dart    # Search input with clear, debounce, focus management
│   │   │   ├── tag_input_field.dart   # Chip-based tag input with autocomplete
│   │   │   ├── stepper_input.dart     # Number stepper: label + [−] value [+]
│   │   │   └── color_picker.dart      # 6-circle color selector for folders/decks
│   │   │
│   │   ├── cards/
│   │   │   ├── app_card.dart          # Base card: outlined, subtle border, no shadow, 16dp radius
│   │   │   ├── stat_card.dart         # Number + label card for stats display
│   │   │   ├── info_bar.dart          # Subtle info row (surface-variant bg, icon + text)
│   │   │   └── selectable_card.dart   # Card with selected/unselected state + animation
│   │   │
│   │   ├── lists/
│   │   │   ├── app_list_tile.dart     # Standard list row: leading, title, subtitle, trailing
│   │   │   ├── animated_list_view.dart# ListView with staggered fadeIn + slideUp on items
│   │   │   ├── app_slidable_row.dart  # Swipe-to-reveal actions (delete, edit) with undo
│   │   │   ├── reorderable_list.dart  # Drag-to-reorder with handle icon
│   │   │   └── expandable_tile.dart   # Tap to expand/collapse with smooth animation
│   │   │
│   │   ├── progress/
│   │   │   ├── mastery_ring.dart      # Circular progress, customizable size + stroke + color
│   │   │   ├── mastery_bar.dart       # Thin horizontal bar: coral → amber → teal gradient
│   │   │   ├── progress_bar.dart      # Simple linear progress bar (3dp, rounded, animated)
│   │   │   └── count_up_text.dart     # Animated number counting up from 0 (for stats)
│   │   │
│   │   ├── dialogs/
│   │   │   ├── confirm_dialog.dart    # Title + message + Cancel/Confirm (destructive variant)
│   │   │   ├── input_dialog.dart      # Title + text field + Cancel/Submit
│   │   │   ├── choice_bottom_sheet.dart  # List of options as bottom sheet
│   │   │   └── exit_session_dialog.dart  # "Exit study session?" with warning
│   │   │
│   │   ├── navigation/
│   │   │   ├── app_bottom_nav.dart    # 4-tab bottom navigation (themed, M3 spec)
│   │   │   ├── breadcrumb_bar.dart    # Folder > Subfolder > Deck path display
│   │   │   └── study_top_bar.dart     # Close(×) + title + progress + progress bar
│   │   │
│   │   ├── chips/
│   │   │   ├── status_chip.dart       # New/Learning/Mastered chip with color dot
│   │   │   ├── tag_chip.dart          # Outlined chip for tags
│   │   │   ├── mode_chip.dart         # Study mode chip with emoji + label
│   │   │   └── streak_chip.dart       # 🔥 N — animated appearance on streak
│   │   │
│   │   └── animations/
│   │       ├── fade_in_widget.dart     # Generic fadeIn with optional delay + slideY
│   │       ├── stagger_list.dart       # Applies staggered animation to list children
│   │       ├── flip_card_widget.dart   # 3D flip on Y-axis, reusable for any front/back
│   │       ├── shake_widget.dart       # Horizontal shake for wrong answer feedback
│   │       ├── scale_tap.dart          # Press → scale(0.96) → release → scale(1.0)
│   │       ├── pulse_widget.dart       # Opacity pulse loop (for fill mode underline)
│   │       └── count_up_animation.dart # TweenAnimationBuilder for number count-up
│   │
│   └── providers/                     # ── Shared Riverpod Providers ──
│       ├── theme_mode_provider.dart   # Watch current ThemeMode
│       ├── seed_color_provider.dart   # Watch current seed color for dynamic theme
│       ├── locale_provider.dart       # Current locale (future i18n prep)
│       └── connectivity_provider.dart # Online/offline status (future sync prep)
│
├── features/                          # ━━━ Feature Modules ━━━
│   │
│   ├── folders/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── folder_model.dart  # Isar collection
│   │   │   └── repositories/
│   │   │       └── folder_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── folder_entity.dart # freezed entity (UI-facing)
│   │   │   ├── repositories/
│   │   │   │   └── folder_repository.dart  # abstract interface
│   │   │   └── usecases/
│   │   │       ├── get_root_folders.dart
│   │   │       ├── get_subfolders.dart
│   │   │       ├── create_folder.dart
│   │   │       ├── delete_folder.dart
│   │   │       ├── can_create_subfolder.dart
│   │   │       ├── can_create_deck.dart
│   │   │       └── get_folder_breadcrumb.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── home_screen.dart
│   │       │   └── folder_detail_screen.dart
│   │       ├── widgets/
│   │       │   ├── folder_tile.dart
│   │       │   ├── folder_mastery_ring.dart
│   │       │   ├── create_folder_dialog.dart
│   │       │   ├── folder_type_chooser_sheet.dart
│   │       │   └── delete_folder_confirm_dialog.dart
│   │       └── providers/
│   │           ├── folders_provider.dart
│   │           └── folder_detail_provider.dart
│   │
│   ├── decks/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── deck_model.dart
│   │   │   └── repositories/
│   │   │       └── deck_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── deck_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── deck_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_decks_by_folder.dart
│   │   │       ├── create_deck.dart
│   │   │       ├── delete_deck.dart
│   │   │       └── get_deck_stats.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── deck_detail_screen.dart
│   │       ├── widgets/
│   │       │   ├── deck_tile.dart
│   │       │   ├── deck_stats_row.dart
│   │       │   ├── create_deck_dialog.dart
│   │       │   └── study_mode_sheet.dart
│   │       └── providers/
│   │           ├── decks_provider.dart
│   │           └── deck_detail_provider.dart
│   │
│   ├── cards/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── card_model.dart
│   │   │   └── repositories/
│   │   │       └── card_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── card_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── card_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_cards_by_deck.dart
│   │   │       ├── create_card.dart
│   │   │       ├── create_cards_batch.dart
│   │   │       ├── update_card.dart
│   │   │       ├── delete_card.dart
│   │   │       └── get_due_cards.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── card_create_screen.dart
│   │       │   └── card_edit_screen.dart
│   │       ├── widgets/
│   │       │   ├── card_list_tile.dart
│   │       │   ├── card_form.dart
│   │       │   └── batch_import_view.dart
│   │       └── providers/
│   │           ├── cards_provider.dart
│   │           └── card_form_provider.dart
│   │
│   ├── study/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── study_session_model.dart
│   │   │   │   └── card_review_model.dart
│   │   │   └── repositories/
│   │   │       └── study_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── study_session_entity.dart
│   │   │   │   └── card_review_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── study_repository.dart
│   │   │   ├── srs/
│   │   │   │   ├── srs_engine.dart         # SM-2 algorithm
│   │   │   │   └── fuzzy_matcher.dart      # Levenshtein + normalize
│   │   │   └── engines/
│   │   │       ├── match_engine.dart       # Pair generation + shuffle
│   │   │       ├── guess_engine.dart       # MCQ generation + distractors
│   │   │       └── fill_engine.dart        # Blank prompt generation
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── review_mode_screen.dart
│   │       │   ├── match_mode_screen.dart
│   │       │   ├── guess_mode_screen.dart
│   │       │   ├── recall_mode_screen.dart
│   │       │   └── fill_mode_screen.dart
│   │       ├── widgets/
│   │       │   ├── flashcard_widget.dart    # 3D flip card (uses FlipCardWidget)
│   │       │   ├── rating_buttons_row.dart  # Again/Hard/Good/Easy
│   │       │   ├── match_item_card.dart
│   │       │   ├── guess_option_button.dart
│   │       │   ├── recall_comparison_view.dart
│   │       │   ├── fill_feedback_card.dart
│   │       │   ├── self_assessment_bar.dart # Missed/Partial/Got it
│   │       │   ├── session_complete_view.dart  # Reused across all modes
│   │       │   └── swipe_gesture_wrapper.dart
│   │       └── providers/
│   │           ├── review_provider.dart
│   │           ├── match_provider.dart
│   │           ├── guess_provider.dart
│   │           ├── recall_provider.dart
│   │           └── fill_provider.dart
│   │
│   ├── statistics/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── statistics_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── study_stats.dart        # Records: DailyActivity, MasteryBreakdown, etc.
│   │   │   ├── repositories/
│   │   │   │   └── statistics_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_study_stats.dart
│   │   │       ├── get_streak.dart
│   │   │       ├── get_weekly_activity.dart
│   │   │       ├── get_mastery_breakdown.dart
│   │   │       └── get_difficult_cards.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── statistics_screen.dart
│   │       ├── widgets/
│   │       │   ├── streak_hero_card.dart
│   │       │   ├── weekly_bar_chart.dart    # CustomPainter
│   │       │   ├── mastery_donut_chart.dart # CustomPainter
│   │       │   ├── mode_usage_bars.dart
│   │       │   └── difficult_cards_section.dart
│   │       └── providers/
│   │           └── statistics_provider.dart
│   │
│   ├── settings/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── app_settings.dart       # freezed + SharedPreferences
│   │   │   └── repositories/
│   │   │       └── settings_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── settings_entity.dart
│   │   │   └── repositories/
│   │   │       └── settings_repository.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── settings_screen.dart
│   │       ├── widgets/
│   │       │   ├── theme_selector.dart
│   │       │   ├── color_seed_selector.dart
│   │       │   ├── setting_section.dart
│   │       │   └── setting_row.dart
│   │       └── providers/
│   │           └── settings_provider.dart
│   │
│   └── search/
│       ├── domain/
│       │   └── usecases/
│       │       └── search_all.dart
│       └── presentation/
│           ├── screens/
│           │   └── search_screen.dart
│           ├── widgets/
│           │   └── search_result_tile.dart
│           └── providers/
│               └── search_provider.dart
│
├── gen/                               # ━━━ Generated Files ━━━
│   ├── assets.gen.dart                # flutter_gen asset references
│   └── fonts.gen.dart                 # flutter_gen font references
│
├── l10n/                              # ━━━ Localization (future-proof) ━━━
│   ├── app_en.arb
│   └── app_vi.arb
│
assets/
├── icons/                             # Custom SVG icons (if needed beyond Material)
├── illustrations/                     # Empty state illustrations (simple line art SVGs)
└── fonts/                             # Fallback fonts (if Google Fonts offline needed)

test/
├── core/
│   ├── utils/                         # Unit tests for all utils
│   ├── extensions/                    # Unit tests for extensions
│   └── theme/                         # Theme token consistency tests
├── features/
│   ├── folders/
│   │   ├── domain/                    # Use case unit tests
│   │   └── presentation/             # Widget tests
│   ├── study/
│   │   ├── domain/
│   │   │   ├── srs_engine_test.dart
│   │   │   └── fuzzy_matcher_test.dart
│   │   └── presentation/
│   └── ...
├── shared/
│   └── widgets/                       # Widget tests for shared components
└── integration/                       # Full flow integration tests
```

---

## 🎨 DESIGN TOKENS — Chi tiết Implementation

### 1. Color Tokens

```dart
// lib/core/theme/tokens/color_tokens.dart

/// M3 semantic color roles.
/// KHÔNG import trực tiếp — luôn access qua context.colorScheme hoặc context.colors
abstract final class ColorTokens {
  // ── Seed Colors (cho ColorScheme.fromSeed) ──
  static const Color seedIndigo = Color(0xFF5C6BC0);
  static const Color seedTeal   = Color(0xFF4DB6AC);
  static const Color seedRose   = Color(0xFFE57373);
  static const Color seedAmber  = Color(0xFFFFB74D);
  static const Color seedSlate  = Color(0xFF78909C);
  static const Color seedSage   = Color(0xFF81C784);

  // ── Available Seed Colors (for settings color picker) ──
  static const List<Color> availableSeeds = [
    seedIndigo, seedTeal, seedRose, seedAmber, seedSlate, seedSage,
  ];

  // ── Surface Overrides (warmer than M3 defaults) ──
  static const Color surfaceLight     = Color(0xFFFAFAFA); // warm white
  static const Color surfaceDark      = Color(0xFF1C1C1E); // charcoal
  static const Color onSurfaceLight   = Color(0xFF1D1D1F); // soft black
  static const Color onSurfaceDark    = Color(0xFFE5E5E7);

  // ── Semantic Colors (via ThemeExtension) ──
  static const Color successLight     = Color(0xFF4DB6AC);
  static const Color successDark      = Color(0xFF80CBC4);
  static const Color warningLight     = Color(0xFFFFB74D);
  static const Color warningDark      = Color(0xFFFFCC80);
  static const Color errorLight       = Color(0xFFE57373);
  static const Color errorDark        = Color(0xFFEF9A9A);
  static const Color masteryLight     = Color(0xFF66BB6A);
  static const Color masteryDark      = Color(0xFF81C784);

  // ── Mastery Gradient Stops ──
  static const Color masteryLow       = Color(0xFFE57373); // coral
  static const Color masteryMid       = Color(0xFFFFB74D); // amber
  static const Color masteryHigh      = Color(0xFF4DB6AC); // teal

  // ── Card Status Colors ──
  static const Color statusNew        = Color(0xFF9E9E9E); // gray
  static const Color statusLearning   = Color(0xFFFFB74D); // amber
  static const Color statusReviewing  = Color(0xFF5C6BC0); // indigo
  static const Color statusMastered   = Color(0xFF4DB6AC); // teal

  // ── Rating Colors ──
  static const Color ratingAgain      = Color(0xFFE57373);
  static const Color ratingHard       = Color(0xFFFFB74D);
  static const Color ratingGood       = Color(0xFF5C6BC0);
  static const Color ratingEasy       = Color(0xFF4DB6AC);

  // ── Self-assessment Colors ──
  static const Color selfMissed       = Color(0xFFE57373);
  static const Color selfPartial      = Color(0xFFFFB74D);
  static const Color selfGotIt        = Color(0xFF4DB6AC);
}
```

### 2. Typography Tokens

```dart
// lib/core/theme/tokens/typography_tokens.dart

abstract final class TypographyTokens {
  // ── Font Family ──
  static const String fontFamily = 'Plus Jakarta Sans';

  // ── Font Weights ──
  static const FontWeight regular   = FontWeight.w400;
  static const FontWeight medium    = FontWeight.w500;
  static const FontWeight semiBold  = FontWeight.w600;
  static const FontWeight bold      = FontWeight.w700;

  // ── Letter Spacing ──
  static const double headingSpacing = -0.02;
  static const double bodySpacing    = 0.0;
  static const double labelSpacing   = 0.06;
  static const double sectionSpacing = 0.08;

  // ── Line Heights ──
  static const double headingHeight  = 1.2;
  static const double bodyHeight     = 1.5;
  static const double captionHeight  = 1.4;

  // ── M3 Type Scale (custom sizes) ──
  static const double displayLarge   = 32.0;
  static const double displayMedium  = 28.0;
  static const double headlineLarge  = 24.0;
  static const double headlineMedium = 22.0;
  static const double titleLarge     = 20.0;
  static const double titleMedium    = 18.0;
  static const double titleSmall     = 16.0;
  static const double bodyLarge      = 17.0;
  static const double bodyMedium     = 15.0;
  static const double bodySmall      = 14.0;
  static const double labelLarge     = 14.0;
  static const double labelMedium    = 13.0;
  static const double labelSmall     = 12.0;
  static const double caption        = 11.0;

  // ── Max Line Width (readability) ──
  static const int maxCharsPerLine   = 60;
}
```

### 3. Spacing Tokens

```dart
// lib/core/theme/tokens/spacing_tokens.dart

abstract final class SpacingTokens {
  // ── Base Grid: 4dp ──
  static const double xxs  = 2.0;
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 24.0;
  static const double xxl  = 32.0;
  static const double xxxl = 48.0;

  // ── Semantic Spacing ──
  static const double cardPadding       = 16.0;
  static const double screenPadding     = 24.0;  // horizontal
  static const double sectionGap        = 32.0;
  static const double listItemGap       = 8.0;
  static const double buttonGap         = 8.0;
  static const double fieldGap          = 20.0;
  static const double chipGap           = 8.0;
  static const double dividerIndent     = 56.0;  // align with text after leading icon
}
```

### 3b. Size Tokens (Component Dimensions)

```dart
// lib/core/theme/tokens/size_tokens.dart

/// Fixed component sizes — NOT spacing between things.
/// Spacing = distance between elements (SpacingTokens).
/// Size = dimensions OF an element (SizeTokens).
abstract final class SizeTokens {
  // ── Touch Targets (M3 minimum) ──
  static const double touchTarget       = 48.0;

  // ── Icons ──
  static const double iconXs            = 16.0;  // inline indicators, status dots
  static const double iconSm            = 20.0;  // button icons, chip icons
  static const double iconMd            = 24.0;  // standard M3 icon size
  static const double iconLg            = 32.0;  // empty state secondary
  static const double iconXl            = 64.0;  // empty state primary

  // ── Avatars ──
  static const double avatarSm          = 24.0;  // inline mentions
  static const double avatarMd          = 32.0;  // app bar, list leading
  static const double avatarLg          = 40.0;  // profile, folder icon container
  static const double avatarXl          = 64.0;  // profile screen

  // ── Buttons ──
  static const double buttonHeight      = 48.0;  // standard M3
  static const double buttonHeightSm    = 36.0;  // compact (e.g. "Check" in fill mode input)
  static const double buttonHeightLg    = 52.0;  // primary CTA ("Study X due cards")
  static const double fabSize           = 56.0;  // standard FAB
  static const double fabSizeSmall      = 40.0;  // small FAB

  // ── Inputs ──
  static const double inputHeight       = 52.0;  // outlined text field
  static const double searchBarHeight   = 48.0;

  // ── List Items ──
  static const double listItemHeight    = 56.0;  // standard row (folder, deck, card)
  static const double listItemCompact   = 52.0;  // compact row (study mode options, settings)
  static const double listItemTall      = 72.0;  // two-line with thumbnail

  // ── Chips ──
  static const double chipHeight        = 32.0;  // M3 standard
  static const double chipHeightSm      = 24.0;  // inline tags, category labels

  // ── Navigation ──
  static const double appBarHeight      = 56.0;  // standard
  static const double appBarHeightLg    = 64.0;  // large/medium top app bar collapsed
  static const double bottomNavHeight   = 80.0;  // M3 NavigationBar
  static const double bottomSheetHandle = 4.0;   // drag handle height
  static const double bottomSheetHandleWidth = 32.0;

  // ── Progress ──
  static const double progressBarHeight = 3.0;   // study mode top bar
  static const double masteryBarHeight  = 4.0;   // deck mastery bar
  static const double masteryRingSize   = 32.0;  // circular progress in folder list
  static const double masteryRingStroke = 2.0;

  // ── Cards (study modes) ──
  static const double flashcardMinHeight = 300.0;
  static const double flashcardMaxHeight = 400.0;
  static const double ratingButtonWidth  = 72.0;
  static const double ratingButtonHeight = 48.0;

  // ── Status Dot ──
  static const double statusDotSize     = 8.0;   // card status indicator
  static const double statusDotSizeLg   = 12.0;  // legend dots in charts

  // ── Dividers ──
  static const double dividerThickness  = 1.0;
  static const double borderWidth       = 1.0;
  static const double borderWidthThick  = 3.0;   // left accent border on comparison cards
}
```

### 4. Radius Tokens

```dart
// lib/core/theme/tokens/radius_tokens.dart

abstract final class RadiusTokens {
  static const double none   = 0.0;
  static const double xs     = 4.0;
  static const double sm     = 8.0;   // chips, small elements
  static const double md     = 12.0;  // buttons, inputs, deck cards
  static const double lg     = 16.0;  // cards, dialogs, sheets
  static const double xl     = 24.0;  // buttons (pill shape)
  static const double xxl    = 28.0;  // FAB
  static const double full   = 100.0; // circular

  // ── Named Shortcuts ──
  static const double card      = lg;
  static const double button    = xl;
  static const double input     = md;
  static const double chip      = sm;
  static const double fab       = xxl;
  static const double dialog    = lg;
  static const double sheet     = lg;
  static const double avatar    = full;
}
```

### 5. Elevation Tokens

```dart
// lib/core/theme/tokens/elevation_tokens.dart

/// M3 uses tonal elevation (surface tint overlay) instead of shadows.
/// These values map to Material 3 elevation levels.
abstract final class ElevationTokens {
  static const double level0 = 0.0;   // flat (default for cards)
  static const double level1 = 1.0;   // subtle lift (pressed card)
  static const double level2 = 3.0;   // FAB resting
  static const double level3 = 6.0;   // FAB pressed, snackbar
  static const double level4 = 8.0;   // navigation drawer
  static const double level5 = 12.0;  // modal (dialog, bottom sheet)

  // ── Shadow Presets (very subtle, for cases where tonal isn't enough) ──
  static const double shadowOpacity = 0.06; // max 8% per design spec
}
```

### 6. Duration Tokens

```dart
// lib/core/theme/tokens/duration_tokens.dart

abstract final class DurationTokens {
  // ── Core Durations ──
  static const Duration instant  = Duration(milliseconds: 50);
  static const Duration fast     = Duration(milliseconds: 100);
  static const Duration normal   = Duration(milliseconds: 200);
  static const Duration slow     = Duration(milliseconds: 300);
  static const Duration slower   = Duration(milliseconds: 500);

  // ── Semantic Durations ──
  static const Duration stateChange     = fast;     // color, border changes
  static const Duration contentSwitch   = normal;   // fade in/out content
  static const Duration pageTransition  = slow;     // route transitions
  static const Duration cardFlip        = Duration(milliseconds: 350);
  static const Duration shake           = slow;
  static const Duration countUp         = Duration(milliseconds: 400);
  static const Duration chartDraw       = Duration(milliseconds: 600);

  // ── Delays ──
  static const Duration staggerDelay    = Duration(milliseconds: 50);
  static const Duration autoAdvance     = Duration(milliseconds: 1200);
  static const Duration ratingPause     = Duration(milliseconds: 800);
  static const Duration wrongClear      = Duration(milliseconds: 500);
  static const Duration debounce        = Duration(milliseconds: 300);
  static const Duration tooltipShow     = Duration(seconds: 2);
}
```

### 7. Easing Tokens

```dart
// lib/core/theme/tokens/easing_tokens.dart

/// M3 motion easing curves.
abstract final class EasingTokens {
  // ── M3 Standard (for most UI transitions) ──
  static const Curve standard            = Curves.easeInOut;

  // ── M3 Emphasized (for large/important transitions) ──
  static const Curve emphasized          = Curves.easeInOutCubicEmphasized;
  static const Curve emphasizedDecelerate = Curves.easeOutCubic;
  static const Curve emphasizedAccelerate = Curves.easeInCubic;

  // ── Convenience ──
  static const Curve enter    = Curves.easeOut;      // elements appearing
  static const Curve exit     = Curves.easeIn;        // elements disappearing
  static const Curve move     = Curves.easeInOut;     // repositioning
  static const Curve bounce   = Curves.elasticOut;    // DON'T use — listed as anti-pattern reminder
}
```

### 8. Opacity / State Layer Tokens

```dart
// lib/core/theme/tokens/opacity_tokens.dart

/// M3 state layer opacities.
abstract final class OpacityTokens {
  // ── State Layers ──
  static const double hover     = 0.08;
  static const double focus     = 0.12;
  static const double press     = 0.12;
  static const double drag      = 0.16;
  static const double disabled  = 0.38;

  // ── Content Opacities ──
  static const double hintText       = 0.50;
  static const double disabledText   = 0.38;
  static const double divider        = 0.06;
  static const double borderSubtle   = 0.08;
  static const double overlay        = 0.15;  // swipe gesture overlay
  static const double surfaceScrim   = 0.32;  // behind dialogs
  static const double fadeOut         = 0.40;  // wrong answer, other options
}
```

---

## 🧩 CUSTOM THEME EXTENSIONS

### CustomColors

```dart
// lib/core/theme/color_schemes/custom_colors.dart

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color success;
  final Color warning;
  final Color mastery;
  final Color surfaceDim;

  // Card status
  final Color statusNew;
  final Color statusLearning;
  final Color statusReviewing;
  final Color statusMastered;

  // Rating
  final Color ratingAgain;
  final Color ratingHard;
  final Color ratingGood;
  final Color ratingEasy;

  // Self-assessment
  final Color selfMissed;
  final Color selfPartial;
  final Color selfGotIt;

  // Mastery gradient
  final Color masteryLow;
  final Color masteryMid;
  final Color masteryHigh;

  const CustomColors({required ...all fields...});

  static const light = CustomColors(
    success: ColorTokens.successLight,
    warning: ColorTokens.warningLight,
    // ... map all light values
  );

  static const dark = CustomColors(
    success: ColorTokens.successDark,
    warning: ColorTokens.warningDark,
    // ... map all dark values
  );

  @override
  CustomColors copyWith({...});

  @override
  CustomColors lerp(CustomColors? other, double t) {
    // Color.lerp every field for smooth theme transitions
  }
}
```

### CustomTextStyles

```dart
// lib/core/theme/text_themes/custom_text_styles.dart

/// Text styles that DON'T fit M3 TextTheme scale but are used
/// across multiple screens. Access via context.appTextStyles.
///
/// M3 TextTheme covers: displayLarge..labelSmall (15 slots).
/// These cover: app-specific styles used in 2+ places.
///
/// Rule: if a text style is used in ONLY 1 widget, define it locally.
///       if used in 2+ widgets across features → add here.
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  // ── Study Mode: Flashcard ──
  final TextStyle flashcardFront;    // term: 22sp, 600w, centered
  final TextStyle flashcardBack;     // definition: 17sp, 400w, 1.6 height
  final TextStyle flashcardHint;     // hint text: 12sp, 400w, 20% opacity
  final TextStyle flashcardExample;  // example: 14sp, 400w, italic

  // ── Study Mode: Prompt / Question ──
  final TextStyle questionText;      // fill/guess question: 18sp, 400w, 1.6 height
  final TextStyle recallTerm;        // recall prompt term: 22sp, 600w, centered
  final TextStyle answerCorrect;     // correct answer display: 16sp, 500w

  // ── Statistics ──
  final TextStyle statNumber;        // large stat: 48sp, 600w (streak hero)
  final TextStyle statNumberMd;      // medium stat: 24sp, 600w (donut center)
  final TextStyle statNumberSm;      // small stat: 20sp, 600w (stats row)
  final TextStyle statLabel;         // stat label below number: 12sp, 400w

  // ── Navigation / Headers ──
  final TextStyle appTitle;          // "MemoX" branding: 22sp, 600w
  final TextStyle sectionLabel;      // "MY FOLDERS": 14sp, 500w, uppercase, 0.08em
  final TextStyle breadcrumb;        // folder path: 13sp, 400w, secondary

  // ── Miscellaneous ──
  final TextStyle progressCount;     // "4 / 20": 14sp, 400w, monospace feel
  final TextStyle nextReviewTime;    // "< 1m", "4d": 11sp, 400w, caption
  final TextStyle tagText;           // chip content: 13sp, 400w
  final TextStyle batchPreview;      // "4 cards detected": 13sp, 500w

  const AppTextStyles({required ...all fields...});

  static AppTextStyles fromTextTheme(TextTheme textTheme) {
    final baseFont = GoogleFonts.plusJakartaSans;
    return AppTextStyles(
      flashcardFront: baseFont(
        fontSize: TypographyTokens.headlineLarge,   // 24sp
        fontWeight: TypographyTokens.semiBold,
        height: TypographyTokens.headingHeight,
        letterSpacing: TypographyTokens.headingSpacing,
      ),
      flashcardBack: baseFont(
        fontSize: TypographyTokens.bodyLarge,        // 17sp
        fontWeight: TypographyTokens.regular,
        height: 1.6,
      ),
      statNumber: baseFont(
        fontSize: 48,
        fontWeight: TypographyTokens.semiBold,
        height: 1.1,
        letterSpacing: TypographyTokens.headingSpacing,
      ),
      sectionLabel: baseFont(
        fontSize: TypographyTokens.labelLarge,       // 14sp
        fontWeight: TypographyTokens.medium,
        letterSpacing: TypographyTokens.sectionSpacing, // 0.08em
        // Note: uppercase transform applied in widget, not in TextStyle
      ),
      // ... construct all fields from tokens
    );
  }

  @override
  AppTextStyles copyWith({...});

  @override
  AppTextStyles lerp(AppTextStyles? other, double t) {
    return AppTextStyles(
      flashcardFront: TextStyle.lerp(flashcardFront, other?.flashcardFront, t)!,
      flashcardBack: TextStyle.lerp(flashcardBack, other?.flashcardBack, t)!,
      // ... lerp all fields
    );
  }
}
```

```dart
// Access pattern — thêm vào context_extensions.dart:
AppTextStyles get appTextStyles => theme.extension<AppTextStyles>()!;

// Usage:
Text(card.front, style: context.appTextStyles.flashcardFront)
Text('14', style: context.appTextStyles.statNumber.copyWith(color: context.colors.primary))
Text('MY FOLDERS', style: context.appTextStyles.sectionLabel)
```
```

---

## 🔌 CONTEXT EXTENSIONS

```dart
// lib/core/extensions/context_extensions.dart

extension BuildContextX on BuildContext {
  // ── Theme Access ──
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  CustomColors get customColors => theme.extension<CustomColors>()!;
  AppTextStyles get appTextStyles => theme.extension<AppTextStyles>()!;
  bool get isDark => theme.brightness == Brightness.dark;

  // ── Media Query ──
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this); // keyboard
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  // ── Responsive ──
  ScreenType get screenType => ScreenType.of(this);
  bool get isCompact => screenType == ScreenType.compact;
  bool get isMedium => screenType == ScreenType.medium;
  bool get isExpanded => screenType == ScreenType.expanded;

  // ── Navigation ──
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  // ── Feedback ──
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? customColors.ratingAgain : null,
      ),
    );
  }

  Future<T?> showAppBottomSheet<T>(Widget child) {
    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => child,
    );
  }

  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: this,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        isDestructive: isDestructive,
      ),
    );
  }
}
```

---

## 📐 RESPONSIVE SYSTEM

```dart
// lib/core/responsive/breakpoints.dart

abstract final class Breakpoints {
  static const double compact  = 0;     // phone portrait
  static const double medium   = 600;   // phone landscape, small tablet
  static const double expanded = 840;   // tablet, desktop
}

// lib/core/responsive/screen_type.dart

enum ScreenType {
  compact,   // < 600dp — single column, full-width cards
  medium,    // 600-840dp — possible 2-column, larger padding
  expanded;  // > 840dp — multi-pane, desktop-like

  static ScreenType of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= Breakpoints.expanded) return ScreenType.expanded;
    if (width >= Breakpoints.medium) return ScreenType.medium;
    return ScreenType.compact;
  }

  // ── Adaptive Values ──
  double get screenPadding => switch (this) {
    compact  => SpacingTokens.lg,      // 16dp
    medium   => SpacingTokens.xl,      // 24dp
    expanded => SpacingTokens.xxl,     // 32dp
  };

  int get gridColumns => switch (this) {
    compact  => 1,
    medium   => 2,
    expanded => 3,
  };

  double get maxContentWidth => switch (this) {
    compact  => double.infinity,
    medium   => 640.0,
    expanded => 840.0,
  };

  // ── Responsive Text Scaling ──
  // Multiplier applied to AppTextStyles for study mode screens.
  // Standard M3 TextTheme does NOT scale — only app-specific styles do.
  double get textScaleFactor => switch (this) {
    compact  => 1.0,
    medium   => 1.1,    // 10% larger on tablets
    expanded => 1.15,   // 15% larger on desktop
  };

  // ── Study Mode Card Dimensions ──
  double get flashcardWidth => switch (this) {
    compact  => double.infinity,  // full width minus padding
    medium   => 400.0,
    expanded => 480.0,
  };

  double get flashcardHeight => switch (this) {
    compact  => 340.0,
    medium   => 380.0,
    expanded => 420.0,
  };

  // ── Match Mode Column Width ──
  double get matchColumnWidth => switch (this) {
    compact  => double.infinity,  // each column = half screen
    medium   => 260.0,
    expanded => 300.0,
  };
}
```

---

## 🧪 KEY SHARED WIDGETS — Spec

### Gap (Spacing Widget)

```dart
// lib/shared/widgets/layout/spacing.dart

/// SizedBox wrappers tied to SpacingTokens.
/// Usage: Gap.sm, Gap.lg, Gap.section
class Gap extends SizedBox {
  const Gap.xxs({super.key}) : super.square(dimension: SpacingTokens.xxs);
  const Gap.xs({super.key})  : super.square(dimension: SpacingTokens.xs);
  const Gap.sm({super.key})  : super.square(dimension: SpacingTokens.sm);
  const Gap.md({super.key})  : super.square(dimension: SpacingTokens.md);
  const Gap.lg({super.key})  : super.square(dimension: SpacingTokens.lg);
  const Gap.xl({super.key})  : super.square(dimension: SpacingTokens.xl);
  const Gap.xxl({super.key}) : super.square(dimension: SpacingTokens.xxl);
  const Gap.section({super.key}) : super.square(dimension: SpacingTokens.sectionGap);
}
```

### AppAsyncBuilder (NEW — Critical)

```dart
// lib/shared/widgets/feedback/app_async_builder.dart

/// Eliminates repeated .when(data:, loading:, error:) boilerplate.
/// EVERY screen using AsyncValue MUST use this instead of raw .when().
///
/// Usage:
/// AppAsyncBuilder<List<FolderEntity>>(
///   value: ref.watch(rootFoldersProvider),
///   onData: (folders) => FolderListView(folders: folders),
///   onRetry: () => ref.invalidate(rootFoldersProvider),
/// )
class AppAsyncBuilder<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) onData;
  final VoidCallback? onRetry;

  // ── Optional Customization ──
  final Widget Function()? onLoading;          // default: LoadingIndicator()
  final Widget Function(Object error)? onError; // default: ErrorView with retry
  final bool showLoadingOverlay;   // true = overlay on previous data, false = replace
  final bool animate;              // default true: fadeIn transition between states

  const AppAsyncBuilder({
    required this.value,
    required this.onData,
    this.onRetry,
    this.onLoading,
    this.onError,
    this.showLoadingOverlay = false,
    this.animate = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) {
        final child = onData(data);
        if (!animate) return child;
        return FadeInWidget(child: child);       // shared animation widget
      },
      loading: () {
        if (onLoading != null) return onLoading!();
        return const LoadingIndicator();
      },
      error: (error, _) {
        if (onError != null) return onError!(error);
        return ErrorView(
          message: error.toString(),
          onRetry: onRetry,
        );
      },
    );
  }
}
```

### AppSlidableRow (NEW)

```dart
// lib/shared/widgets/lists/app_slidable_row.dart

/// Swipe-to-reveal actions for list items.
/// Used in folder, deck, and card lists.
///
/// Usage:
/// AppSlidableRow(
///   onDelete: () => deleteDeck(deck.id),
///   deleteLabel: context.l10n.delete,
///   confirmDelete: true,
///   child: DeckTile(deck: deck),
/// )
class AppSlidableRow extends StatelessWidget {
  final Widget child;

  // ── Swipe Left Actions (destructive, right side) ──
  final VoidCallback? onDelete;
  final String? deleteLabel;          // default: context.l10n.delete
  final bool confirmDelete;           // default: true → shows ConfirmDialog first
  final String? deleteConfirmMessage; // custom confirm message

  // ── Swipe Right Actions (non-destructive, left side) ──
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;

  // ── Behavior ──
  final bool showUndoSnackbar;        // default: true → shows undo after delete
  final Duration undoDuration;        // default: 4 seconds

  const AppSlidableRow({
    required this.child,
    this.onDelete,
    this.deleteLabel,
    this.confirmDelete = true,
    this.deleteConfirmMessage,
    this.onEdit,
    this.onArchive,
    this.showUndoSnackbar = true,
    this.undoDuration = const Duration(seconds: 4),
    super.key,
  });

  // Implementation: uses flutter_slidable or custom Dismissible
  // Delete action: coral background + white trash icon
  // Edit action: primary background + white edit icon
  // Slide threshold: 0.25 of row width
  // Animation: 300ms ease-out
}
```

### EmptyStateView

```dart
// lib/shared/widgets/feedback/empty_state_view.dart

/// Reusable empty state. Center-aligned, with fadeIn + scale animation.
///
/// Usage:
/// EmptyStateView(
///   icon: Icons.folder_outlined,
///   title: context.l10n.emptyFolders,
///   subtitle: context.l10n.emptyFoldersSubtitle,
///   actionLabel: context.l10n.createFolder,
///   onAction: () => showCreateFolderDialog(context),
/// )
class EmptyStateView extends StatelessWidget {
  final IconData icon;               // 64dp, secondary color
  final String title;                // 18sp, 500w
  final String? subtitle;            // 14sp, caption color
  final String? actionLabel;         // outlined button text
  final VoidCallback? onAction;

  // Visual: center aligned, max width 280dp for text
  // Animation: fadeIn(300ms) + scale(begin: 0.9, 300ms)
  // Icon uses SizeTokens.iconXl (64dp)
  // No illustrations or mascots — icon only
}
```

### AppCard

```dart
// lib/shared/widgets/cards/app_card.dart

/// Standard M3 card. ALL cards in the app MUST use this.
/// DO NOT use raw Card() or Container with BoxDecoration.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;  // default: SpacingTokens.cardPadding all
  final Color? backgroundColor;     // default: surface
  final Color? borderColor;         // default: outline at OpacityTokens.borderSubtle
  final double? borderRadius;       // default: RadiusTokens.card (16dp)
  final Color? leftBorderColor;     // accent border (3dp left side, for comparison cards)
  final bool enabled;               // default: true, false = OpacityTokens.disabled

  // Shape: RoundedRectangle, RadiusTokens.card
  // Border: 1dp, outline color at 8% opacity
  // Shadow: NONE (elevation 0)
  // Tap: InkWell with borderRadius clipping, subtle ripple
  // Disabled: entire card at 38% opacity, no tap
}
```

### PrimaryButton

```dart
// lib/shared/widgets/buttons/primary_button.dart

/// Full-width filled button. Used for main CTA on every screen.
/// "Study 8 due cards", "Save", "Done", "Create Folder"
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;     // null = disabled state
  final bool isLoading;              // shows CircularProgressIndicator inside
  final IconData? icon;              // optional leading icon
  final bool fullWidth;              // default: true
  final double height;               // default: SizeTokens.buttonHeightLg (52dp)

  // Style: filled, primary color, RadiusTokens.button (24dp)
  // Text: 15sp, 500w, white/onPrimary
  // Loading: button stays same size, text replaced with small spinner
  // Disabled: 38% opacity, no tap
  // Press: scale(0.98) via ScaleTap wrapper
}
```

### SecondaryButton

```dart
// lib/shared/widgets/buttons/secondary_button.dart

/// Outlined variant. "Play again", "Cancel", "Show answer"
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;              // default: true
  final double height;               // default: SizeTokens.buttonHeight (48dp)
  final Color? color;                // border + text color override

  // Style: outlined, primary border, transparent fill
  // Press: subtle primary tonal fill (OpacityTokens.press)
}
```

### StudyTopBar

```dart
// lib/shared/widgets/navigation/study_top_bar.dart

/// Consistent top bar across ALL 5 study modes.
/// Close(×) + title + "4/20" progress + streak chip (optional)
/// + thin progress bar below
class StudyTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;            // "Review", "Match", etc.
  final int current;
  final int total;
  final int? streak;             // show streak chip if >= threshold
  final int streakThreshold;     // default 2 for guess, 3 for fill
  final VoidCallback onClose;    // shows ExitSessionDialog, then pops

  // Height: SizeTokens.appBarHeight (56dp) including progress bar
  // Close button: Icons.close_outlined, left side
  // Title: 16sp, 500w, center
  // Progress text: "4/20", 14sp, secondary, right of title
  // Streak chip: "🔥 5", only visible when streak >= threshold
  //   Animation: scale pulse (1.0→1.2→1.0, 200ms) when streak increases
  // Progress bar: 3dp height, bottom of bar, animated width
  //   Track: surfaceVariant, Fill: primary color
  //   Animation: width transition 300ms ease-out
}
```

### MasteryBar

```dart
// lib/shared/widgets/progress/mastery_bar.dart

/// Thin gradient progress bar: coral(0%) → amber(50%) → teal(100%)
class MasteryBar extends StatelessWidget {
  final double percentage;       // 0.0 - 1.0
  final double height;           // default: SizeTokens.masteryBarHeight (4dp)
  final bool animate;            // default: true, animates width change

  // Track: surface-variant, rounded caps
  // Fill: LinearGradient using customColors.masteryLow/Mid/High
  // Animation: width tween, DurationTokens.slow (300ms)
  // Rounded: full radius on both track and fill
}
```

### MasteryRing

```dart
// lib/shared/widgets/progress/mastery_ring.dart

/// Circular progress indicator for folder/deck lists.
class MasteryRing extends StatelessWidget {
  final double percentage;       // 0.0 - 1.0
  final double size;             // default: SizeTokens.masteryRingSize (32dp)
  final double strokeWidth;      // default: SizeTokens.masteryRingStroke (2dp)
  final bool showPercentText;    // default: false (show % number in center)

  // Track: surfaceVariant, circular
  // Fill: primary color, animated sweep angle
  // Animation: DurationTokens.chartDraw (600ms) on first build
  // CustomPainter based — not CircularProgressIndicator
}
```

### SessionCompleteView (Shared across 5 modes)

```dart
// lib/shared/widgets/feedback/session_complete_view.dart

/// Displayed when any study session finishes.
/// Configurable stats rows + mode-specific content slot.
///
/// Usage (in Review mode):
/// SessionCompleteView(
///   stats: [
///     SessionStat(label: context.l10n.cardsReviewed(20), icon: Icons.style_outlined),
///     SessionStat(label: context.l10n.accuracy(85), icon: Icons.check_circle_outline),
///     SessionStat(label: '12 min', icon: Icons.timer_outlined),
///   ],
///   primaryAction: SessionAction(label: context.l10n.done, onTap: () => context.pop()),
///   secondaryAction: SessionAction(label: context.l10n.studyMore, onTap: startNewSession),
/// )
class SessionCompleteView extends StatelessWidget {
  final List<SessionStat> stats;           // 2-5 stat rows
  final SessionAction primaryAction;        // filled button ("Done")
  final SessionAction? secondaryAction;     // text link ("Study more", "Review missed")
  final Widget? extraContent;               // mode-specific slot (e.g. expandable mistakes list)

  // Layout:
  //   Checkmark circle: 64dp, teal outline, SizeTokens.iconXl
  //   "Session complete": 20sp, 600w (context.appTextStyles.statNumberSm analog)
  //   Stats: vertical list, each row = icon(16dp) + text(15sp)
  //   Primary button: PrimaryButton (full width)
  //   Secondary: TextLinkButton below primary
  // Animation: fadeIn(300ms) + scale(begin: 0.95)
  // NO confetti, NO celebration animation
}

@freezed
class SessionStat with _$SessionStat {
  const factory SessionStat({
    required String label,
    required IconData icon,
    Color? valueColor,    // optional: teal for good, coral for bad
  }) = _SessionStat;
}

@freezed
class SessionAction with _$SessionAction {
  const factory SessionAction({
    required String label,
    required VoidCallback onTap,
  }) = _SessionAction;
}
```

### AnimatedListView

```dart
// lib/shared/widgets/lists/animated_list_view.dart

/// ListView that animates children in with staggered fadeIn + slideUp.
/// Used for folder, deck, and card lists.
class AnimatedListView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool shrinkWrap;                  // default: false
  final Duration staggerDelay;            // default: DurationTokens.staggerDelay (50ms)
  final Duration itemDuration;            // default: DurationTokens.normal (200ms)

  // Each child wrapped in FadeInWidget with:
  //   delay: index * staggerDelay
  //   fadeIn + slideY(begin: 0.05)
  // Uses flutter_animate for orchestration
}
```

### Other Shared Widget Specs (Compact Reference)

```dart
// ── Layout ──
// app_scaffold.dart      → AppScaffold(body, appBar?, fab?, useSafeArea, extendBehindAppBar)
//                          Handles: responsive padding, maxWidth, SafeArea
// section_container.dart → SectionContainer(title, action?, child)
//                          Title: sectionLabel style (14sp, uppercase, 0.08em)
//                          Action: TextLinkButton at trailing end
// adaptive_layout.dart   → AdaptiveLayout(compactBody, expandedBody?, breakpoint?)
//                          Shows one or two panes based on ScreenType
// sliver_scaffold.dart   → SliverScaffold(title, expandedHeight?, slivers, fab?)
//                          CustomScrollView with SliverAppBar (collapsing header)

// ── Feedback ──
// loading_indicator.dart → LoadingIndicator(size?) — centered M3 spinner, default 36dp
// loading_overlay.dart   → LoadingOverlay(isLoading, child) — semi-transparent scrim + spinner
// error_view.dart        → ErrorView(message, onRetry?) — error icon + message + "Try again" button
// success_indicator.dart → SuccessIndicator(size?) — animated checkmark circle, teal, 64dp default
// toast.dart             → Toast.show(context, message, {type: success/error/info})
//                          Wraps ScaffoldMessenger, styled per type, auto-dismiss 4s

// ── Buttons ──
// text_link_button.dart  → TextLinkButton(label, onTap, {color?})
//                          Minimal: no background, primary text, "→" suffix optional
//                          13-14sp, 500w, subtle press state
// icon_action_button.dart→ IconActionButton(icon, onTap, {tooltip, size})
//                          M3 IconButton with tooltip, outlined style, 48dp touch target
// app_fab.dart            → AppFab(icon, onTap, {label?, heroTag?})
//                          56dp, primary container, RadiusTokens.fab
//                          Extended variant if label provided

// ── Inputs ──
// app_text_field.dart    → AppTextField(controller, label, hint?, error?, maxLines,
//                            maxLength?, showCounter?, onChanged?, keyboardType?)
//                          M3 outlined, RadiusTokens.input, SizeTokens.inputHeight
//                          Error state: coral border + error text below
// app_search_bar.dart    → AppSearchBar(onChanged, hint?, autofocus?)
//                          Built-in debounce (DurationTokens.debounce), clear button
//                          SizeTokens.searchBarHeight, leading search icon
// tag_input_field.dart   → TagInputField(tags, suggestions, onChanged, maxTags?)
//                          Chip-based, autocomplete dropdown, "×" to remove
// stepper_input.dart     → StepperInput(value, onChanged, min, max, step, label)
//                          [−] value [+] row, disabled at min/max
// color_picker.dart      → ColorPicker(selectedColor, onChanged, colors?)
//                          6 circles from ColorTokens.availableSeeds
//                          Selected: checkmark overlay, 40dp each

// ── Cards ──
// stat_card.dart          → StatCard(value, label, {valueColor?, icon?})
//                          Number: statNumberSm style, Label: statLabel style
//                          Used in deck stats row (4 items)
// info_bar.dart            → InfoBar(icon, text, {onTap?})
//                          surface-variant bg, 8dp radius, 12dp vertical padding
//                          Full width, used for folder status indicator
// selectable_card.dart    → SelectableCard(isSelected, onTap, child)
//                          Selected: primary tonal bg, scale(1.02), 200ms transition
//                          Used in Match mode items

// ── Lists ──
// app_list_tile.dart      → AppListTile(title, subtitle?, leading?, trailing?, onTap?)
//                          SizeTokens.listItemHeight, divider at bottom (optional)
//                          Leading: 40dp container, Trailing: icon or widget
// reorderable_list.dart   → ReorderableListWidget(items, onReorder, itemBuilder)
//                          Drag handle icon at leading, haptic on grab
// expandable_tile.dart    → ExpandableTile(header, expandedContent, initiallyExpanded?)
//                          Smooth height animation (DurationTokens.normal)
//                          Chevron rotates 180° on expand

// ── Progress ──
// progress_bar.dart       → ProgressBar(progress, {height?, color?, trackColor?})
//                          Default: SizeTokens.progressBarHeight (3dp), rounded
//                          Animated width, DurationTokens.slow
// count_up_text.dart      → CountUpText(endValue, style, {duration?, prefix?, suffix?})
//                          TweenAnimationBuilder, DurationTokens.countUp (400ms)
//                          Used in statistics screen numbers

// ── Dialogs ──
// confirm_dialog.dart     → ConfirmDialog(title, message, confirmText, {isDestructive?})
//                          Destructive: coral confirm button text
//                          Returns Future<bool?> (true = confirmed)
// input_dialog.dart       → InputDialog(title, hint, {initialValue?, validator?})
//                          Single text field + Cancel/Submit
//                          Returns Future<String?> (null = cancelled)
// choice_bottom_sheet.dart→ ChoiceBottomSheet<T>(title, options: List<ChoiceOption<T>>)
//                          List of options with icon + title + subtitle
//                          Returns Future<T?> (selected value)
// exit_session_dialog.dart→ ExitSessionDialog() — pre-built confirm dialog
//                          "Exit study session?" + "Progress won't be saved"
//                          Returns Future<bool?> (true = exit)

// ── Navigation ──
// app_bottom_nav.dart     → AppBottomNav(currentIndex, onTap)
//                          4 tabs: Home, Library, Progress, Settings
//                          M3 NavigationBar spec: icon + label when selected
//                          SizeTokens.bottomNavHeight (80dp)
// breadcrumb_bar.dart     → BreadcrumbBar(segments: List<BreadcrumbSegment>)
//                          "Home → Japanese N5 → Vocabulary"
//                          Each segment tappable, last segment = current (bold)
//                          13sp, secondary color, "→" separator

// ── Chips ──
// status_chip.dart        → StatusChip(status: CardStatus)
//                          Auto-maps status to color + label
//                          Small dot (8dp) + text, outlined style
// tag_chip.dart            → TagChip(label, {onTap?, onDelete?})
//                          Outlined, RadiusTokens.chip, compact
// mode_chip.dart           → ModeChip(mode: StudyMode, {isSelected?})
//                          Emoji circle + mode name, outlined
// streak_chip.dart         → StreakChip(count)
//                          "🔥 N", animated appearance (scale in)
//                          Only renders when count >= 2

// ── Animations ──
// fade_in_widget.dart     → FadeInWidget(child, {delay?, duration?, slideY?})
//                          Default: fadeIn 200ms + optional slideY(begin: 0.05)
// stagger_list.dart       → StaggerList(children, {staggerDelay?, itemDuration?})
//                          Wraps each child in FadeInWidget with incremental delay
// flip_card_widget.dart   → FlipCardWidget(front, back, isFlipped, {duration?})
//                          3D Y-axis flip, scale 0.96 at midpoint
//                          DurationTokens.cardFlip (350ms)
// shake_widget.dart       → ShakeWidget(child, isShaking)
//                          Horizontal: 4dp amplitude, DurationTokens.shake
// scale_tap.dart           → ScaleTap(child, onTap, {scaleDown?})
//                          Press: scale(0.96), release: scale(1.0), 100ms
// pulse_widget.dart        → PulseWidget(child, {minOpacity?, maxOpacity?, duration?})
//                          Opacity loop: 60%→100%, 1.5s, ease-in-out
//                          Used for fill mode blank underline
// count_up_animation.dart → CountUpAnimation(end, builder, {duration?, curve?})
//                          TweenAnimationBuilder wrapper, generic
```

---

## 🔗 MIXINS — Spec

### LoadingMixin

```dart
// lib/core/mixins/loading_mixin.dart

/// For Riverpod AsyncNotifiers or any class managing async state.
mixin LoadingMixin {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Wrap any async operation with loading/error handling.
  Future<T?> guard<T>(Future<T> Function() action) async {
    _isLoading = true;
    _error = null;
    try {
      final result = await action();
      return result;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }
}
```

### ScrollMixin

```dart
// lib/core/mixins/scroll_mixin.dart

/// For StatefulWidgets needing scroll tracking.
mixin ScrollMixin<T extends StatefulWidget> on State<T> {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  bool get isAtBottom {
    final max = scrollController.position.maxScrollExtent;
    return scrollController.offset >= max - 50;
  }

  void scrollToTop({bool animated = true}) { ... }

  void _onScroll() {
    if (isAtBottom) onScrollEnd();
  }

  /// Override for pagination, lazy loading, etc.
  void onScrollEnd() {}
}
```

---

## 📋 CHECKLIST — Những gì codebase này bao gồm

```
✅ Design Token System
   ├── Color tokens (semantic roles, seed palette, status, rating, mastery gradient)
   ├── Typography tokens (type scale, weights, spacing, line heights)
   ├── Spacing tokens (4dp grid, semantic names — distances between elements)
   ├── Size tokens (component dimensions — icon, avatar, button, input, nav heights)
   ├── Radius tokens (xs→full, named shortcuts for components)
   ├── Elevation tokens (M3 tonal levels, shadow presets)
   ├── Duration tokens (core + semantic + delays)
   ├── Easing tokens (M3 motion curves)
   └── Opacity tokens (state layers + content opacities)

✅ Theme System
   ├── Light/Dark ColorScheme from seed
   ├── CustomColors ThemeExtension with lerp support
   ├── AppTextStyles ThemeExtension (flashcard, stat, section, breadcrumb styles)
   ├── Per-component theme overrides (14 component themes)
   ├── Dynamic theme switching (seed color change)
   └── GoogleFonts integration

✅ Responsive Design
   ├── Breakpoint definitions (compact/medium/expanded)
   ├── ScreenType enum with adaptive values
   ├── Responsive text scaling (textScaleFactor per breakpoint)
   ├── Adaptive study mode sizing (flashcard, match column dimensions)
   ├── ResponsiveBuilder widget
   ├── Adaptive padding, grid columns, max content width
   └── Responsive widget helpers

✅ Shared Widgets (40+ components, ALL with constructor specs)
   ├── Layout: scaffold, section, adaptive layout, sliver, spacing
   ├── Feedback: async builder, loading, error, empty state, success, session complete, toast
   ├── Buttons: primary, secondary, text link, icon, FAB
   ├── Inputs: text field, search bar, tag input, stepper, color picker
   ├── Cards: base card, stat card, info bar, selectable card
   ├── Lists: list tile, animated list, slidable row, reorderable, expandable
   ├── Progress: mastery ring, mastery bar, progress bar, count-up
   ├── Dialogs: confirm, input, choice sheet, exit session
   ├── Navigation: bottom nav, breadcrumb, study top bar
   ├── Chips: status, tag, mode, streak
   └── Animations: fade in, stagger, flip, shake, scale tap, pulse, count-up

✅ Utils (9 utility modules)
   ├── date, string, color, number, duration, file
   ├── debouncer, throttler
   └── validators

✅ Extensions (10 extension files)
   ├── context (theme, media query, responsive, navigation, feedback)
   ├── theme, color, datetime, string
   ├── list, num, widget, duration, iterable
   └── All providing type-safe shortcuts

✅ Mixins (7 behavior mixins)
   ├── loading, form validation, auto dispose
   ├── scroll, keyboard, haptic
   └── after layout

✅ Error Handling
   ├── Sealed exception classes
   ├── Global error handler
   └── Failure records for use case results

✅ Database Layer
   ├── Isar provider (Riverpod)
   ├── DB initializer
   └── Migration handler

✅ Services
   ├── Notification, Share, FilePicker, Haptic
   └── All abstracted for testability

✅ Architecture
   ├── Feature-first Clean Architecture
   ├── data → domain → presentation per feature
   ├── Abstract repositories in domain, impl in data
   ├── Use cases as single-responsibility classes
   └── Riverpod generators (@riverpod) for providers

✅ Testing Structure
   ├── Mirrors lib/ structure
   ├── core/, features/, shared/, integration/
   └── Unit + Widget + Integration test locations

✅ Future-proofing
   ├── l10n setup (ARB files ready)
   ├── gen/ for asset generation
   ├── Connectivity provider (for future sync)
   └── Locale provider (for future i18n)
```

---

## 💡 Nguyên tắc sử dụng

**Rule 1 — Không bao giờ hardcode**
```dart
// ❌ WRONG
Container(padding: EdgeInsets.all(16), ...)
Text('Hello', style: TextStyle(fontSize: 14, color: Colors.grey))

// ✅ RIGHT
Container(padding: EdgeInsets.all(SpacingTokens.lg), ...)
Text('Hello', style: context.textTheme.bodySmall)
```

**Rule 2 — Luôn dùng context extensions**
```dart
// ❌ WRONG
Theme.of(context).colorScheme.primary
Theme.of(context).extension<CustomColors>()!.success

// ✅ RIGHT
context.colors.primary
context.customColors.success
```

**Rule 3 — Shared widget trước, custom widget sau**
```dart
// Trước khi tạo widget mới, check:
// 1. shared/widgets/ đã có chưa?
// 2. Có thể mở rộng widget có sẵn không?
// 3. Widget mới có thể reuse ở feature khác không? → nếu có → shared/
```

**Rule 4 — Token trước, magic number sau (never)**
```dart
// ❌ WRONG
Duration(milliseconds: 200)
BorderRadius.circular(16)

// ✅ RIGHT
DurationTokens.normal
BorderRadius.circular(RadiusTokens.card)
```

**Rule 5 — AsyncValue luôn dùng AppAsyncBuilder**
```dart
// ❌ WRONG — duplicate loading/error pattern ở mỗi screen
final folders = ref.watch(rootFoldersProvider);
return folders.when(
  data: (list) => FolderListView(folders: list),
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, _) => Center(child: Text('Error: $e')),
);

// ✅ RIGHT
final folders = ref.watch(rootFoldersProvider);
return AppAsyncBuilder(
  value: folders,
  onData: (list) => FolderListView(folders: list),
  onRetry: () => ref.invalidate(rootFoldersProvider),
);
```

**Rule 6 — Component sizes dùng SizeTokens, spacing dùng SpacingTokens**
```dart
// ❌ WRONG — nhầm lẫn size và spacing
SizedBox(height: SpacingTokens.lg)  // 16dp gap — OK, this IS spacing
Icon(Icons.folder, size: SpacingTokens.xl)  // ← WRONG: icon size ≠ spacing

// ✅ RIGHT
const Gap.lg()                                    // spacing between elements
Icon(Icons.folder, size: SizeTokens.iconMd)       // component dimension
SizedBox(height: SizeTokens.buttonHeightLg)       // component dimension
```
