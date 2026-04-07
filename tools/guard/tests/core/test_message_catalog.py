from __future__ import annotations

import unittest

from tools.guard.core.message_catalog import MessageCatalog, MessageCatalogError


class MessageCatalogTest(unittest.TestCase):
    def test_resolve_catalog_entry_renders_message_and_remediation(self) -> None:
        catalog = MessageCatalog.from_config({
            'message_catalog': {
                'no_else.forbidden_else': {
                    'template': 'Use early return in {file_name}.',
                    'suggestion': 'Return early from {file_name}.',
                    'remediation_id': 'use_early_return',
                    'docs_ref': 'rules/no_else',
                },
            },
            'remediation_catalog': {
                'use_early_return': {
                    'title': 'Remove else branch',
                    'summary': 'Replace else with an early return in {file_name}.',
                    'manual_steps': [
                        'Return from the exceptional branch.',
                        'Keep {file_name} on the main path.',
                    ],
                },
            },
        })

        resolved = catalog.resolve(
            code='no_else.forbidden_else',
            params={'file_name': 'foo.dart'},
        )

        self.assertEqual(resolved.code, 'no_else.forbidden_else')
        self.assertEqual(resolved.message, 'Use early return in foo.dart.')
        self.assertEqual(resolved.suggestion, 'Return early from foo.dart.')
        self.assertEqual(resolved.docs_ref, 'rules/no_else')
        self.assertEqual(resolved.remediation['title'], 'Remove else branch')
        self.assertEqual(
            resolved.remediation['summary'],
            'Replace else with an early return in foo.dart.',
        )

    def test_missing_code_falls_back_to_literal_message(self) -> None:
        catalog = MessageCatalog.from_config({})

        resolved = catalog.resolve(
            code='missing.code',
            params={'file_name': 'foo.dart'},
            fallback_message='Fallback for {file_name}.',
        )

        self.assertEqual(resolved.code, 'missing.code')
        self.assertEqual(resolved.message, 'Fallback for foo.dart.')
        self.assertIsNone(resolved.remediation)

    def test_missing_code_without_fallback_returns_clear_placeholder(self) -> None:
        catalog = MessageCatalog.from_config({})

        resolved = catalog.resolve(code='missing.code')

        self.assertEqual(resolved.message, 'Missing message catalog entry: missing.code')

    def test_invalid_remediation_reference_raises_clear_error(self) -> None:
        with self.assertRaises(MessageCatalogError) as ctx:
            MessageCatalog.from_config({
                'message_catalog': {
                    'broken.code': {
                        'template': 'Broken',
                        'remediation_id': 'does_not_exist',
                    },
                },
            })

        self.assertIn('unknown remediation_catalog entry', str(ctx.exception))


if __name__ == '__main__':
    unittest.main()
