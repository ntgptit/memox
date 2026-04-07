from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.srs_field_guard import SrsFieldGuard


def _make_paths(root: Path) -> PathConstants:
    return PathConstants.from_config(root, {
        'source_root': 'lib',
        'test_root': 'test',
        'paths': {
            'core_dir': 'lib/core',
            'shared_dir': 'lib/shared',
            'features_dir': 'lib/features',
            'exclude_patterns': [],
        },
        'language_extensions': ['.dart'],
    })


class SrsFieldGuardTest(unittest.TestCase):
    def test_catalog_backed_legacy_violation_uses_message_code(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            target = root / 'lib/core/database/tables/cards_table.dart'
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(
                'class CardsTable {\n'
                '  IntColumn get status => integer()();\n'
                '}\n',
                encoding='utf-8',
            )

            config = {
                'message_catalog': {
                    'srs_field.missing_required_column': {
                        'template': 'Cards table thiếu SRS field `{column}`.',
                        'suggestion': 'Add `{column}` to the cards table.',
                        'remediation_id': 'add_srs_field',
                    },
                },
                'remediation_catalog': {
                    'add_srs_field': {
                        'title': 'Add missing SRS column',
                        'summary': 'Declare `{column}` in cards_table.dart.',
                        'manual_steps': ['Add `{column}` to the table definition.'],
                    },
                },
            }
            guard = SrsFieldGuard(
                config=config,
                path_constants=_make_paths(root),
                project_rules={
                    'srs_fields': {
                        'target_file': 'lib/core/database/tables/cards_table.dart',
                        'missing_column_message_code': 'srs_field.missing_required_column',
                        'missing_column_message': 'Cards table thiếu SRS field `{column}`.',
                        'cards_table': {
                            'required_columns': ['status', 'easeFactor'],
                        },
                    },
                },
            )

            violations = guard.check_project([])

            self.assertEqual(len(violations), 1)
            self.assertEqual(
                violations[0].violation_code,
                'srs_field.missing_required_column',
            )
            self.assertEqual(
                violations[0].message_ref,
                'srs_field.missing_required_column',
            )
            self.assertEqual(
                violations[0].message,
                'Cards table thiếu SRS field `easeFactor`.',
            )
            self.assertEqual(
                violations[0].suggestion,
                'Add `easeFactor` to the cards table.',
            )
            self.assertEqual(
                violations[0].remediation['title'],
                'Add missing SRS column',
            )


if __name__ == '__main__':
    unittest.main()
