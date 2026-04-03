from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.typography_scale_guard import TypographyScaleGuard


class TypographyScaleGuardTest(unittest.TestCase):
    def test_reports_missing_required_typography_contract_tokens(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib/core/theme/tokens').mkdir(parents=True)
            (root / 'docs').mkdir(parents=True)
            (root / 'lib/core/theme/tokens/typography_tokens.dart').write_text(
                'abstract final class TypographyTokens {}',
                encoding='utf-8',
            )
            (root / 'AGENTS.md').write_text(
                'Typography usage rules',
                encoding='utf-8',
            )
            (root / 'docs/memox-typography-usage-rules.md').write_text(
                '# MemoX Typography Usage Rules',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_project([])

            self.assertEqual(len(violations), 3)
            self.assertTrue(
                any(
                    '48 / 32 / 24 / 20 / 16 / 14 / 12' in violation.message
                    for violation in violations
                )
            )

    def test_passes_when_code_and_docs_match_typography_contract(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib/core/theme/tokens').mkdir(parents=True)
            (root / 'docs').mkdir(parents=True)
            (root / 'lib/core/theme/tokens/typography_tokens.dart').write_text(
                '\n'.join(
                    [
                        '// ── Collapsed Type Scale (48 / 32 / 24 / 20 / 16 / 14 / 12) ──',
                        'static const double displayLarge = 32;',
                        'static const double displayMedium = 32;',
                        'static const double statDisplay = 48;',
                        'static const double headlineLarge = 24;',
                        'static const double headlineMedium = 20;',
                        'static const double titleLarge = 24;',
                        'static const double titleMedium = 16;',
                        'static const double titleSmall = 16;',
                        'static const double bodyLarge = 16;',
                        'static const double bodyMedium = 16;',
                        'static const double bodySmall = 14;',
                        'static const double labelLarge = 14;',
                        'static const double labelMedium = 12;',
                        'static const double labelSmall = 12;',
                        'static const double caption = 12;',
                    ]
                ),
                encoding='utf-8',
            )
            (root / 'AGENTS.md').write_text(
                '\n'.join(
                    [
                        'MemoX uses a constrained app type scale only: '
                        '`48 / 32 / 24 / 20 / 16 / 14 / 12`.',
                        '`20` (`headlineMedium`) is the bridge headline size.',
                    ]
                ),
                encoding='utf-8',
            )
            (root / 'docs/memox-typography-usage-rules.md').write_text(
                '\n'.join(
                    [
                        'MemoX uses a constrained app type scale only:',
                        '- `20` — bridge headline',
                        '- Do not introduce new size steps outside '
                        '`48 / 32 / 24 / 20 / 16 / 14 / 12`.',
                    ]
                ),
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_project([])

            self.assertEqual(violations, [])

    def _create_guard(self, root: Path) -> TypographyScaleGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'local_guards': {'typography_scale': True},
        }
        rules = {
            'typography_scale': {
                'cases': [
                    {
                        'file': 'lib/core/theme/tokens/typography_tokens.dart',
                        'required_tokens': [
                            '48 / 32 / 24 / 20 / 16 / 14 / 12',
                            'static const double displayLarge = 32;',
                            'static const double displayMedium = 32;',
                            'static const double statDisplay = 48;',
                            'static const double headlineLarge = 24;',
                            'static const double headlineMedium = 20;',
                            'static const double titleLarge = 24;',
                            'static const double titleMedium = 16;',
                            'static const double titleSmall = 16;',
                            'static const double bodyLarge = 16;',
                            'static const double bodyMedium = 16;',
                            'static const double bodySmall = 14;',
                            'static const double labelLarge = 14;',
                            'static const double labelMedium = 12;',
                            'static const double labelSmall = 12;',
                            'static const double caption = 12;',
                        ],
                    },
                    {
                        'file': 'AGENTS.md',
                        'required_tokens': [
                            '48 / 32 / 24 / 20 / 16 / 14 / 12',
                            '`20` (`headlineMedium`) is the bridge headline size',
                        ],
                    },
                    {
                        'file': 'docs/memox-typography-usage-rules.md',
                        'required_tokens': [
                            'constrained app type scale only',
                            '`20` — bridge headline',
                            '`48 / 32 / 24 / 20 / 16 / 14 / 12`',
                        ],
                    },
                ]
            }
        }
        paths = PathConstants.from_config(root, config)
        return TypographyScaleGuard(
            config=config,
            path_constants=paths,
            project_rules=rules,
        )


if __name__ == '__main__':
    unittest.main()
