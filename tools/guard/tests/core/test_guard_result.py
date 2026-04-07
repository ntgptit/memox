from __future__ import annotations

import unittest

from tools.guard.core.guard_result import (
    GuardResult,
    GuardScope,
    RESULT_SCHEMA_VERSION,
    Severity,
    VIOLATION_SCHEMA_VERSION,
    Violation,
    ViolationSchemaError,
    ViolationSource,
)


class ViolationSchemaTest(unittest.TestCase):
    def test_create_builds_canonical_v2_violation(self) -> None:
        violation = Violation.create(
            file_path='lib/foo.dart',
            line_number=3,
            line_content='} else {',
            message='Use early return instead of else.',
            guard_id='no_else',
            severity=Severity.ERROR,
            scope=GuardScope.GLOBAL,
            category='style',
            column_number=5,
            symbol='FooWidget.build',
            suggestion='Return early from the exceptional branch.',
            remediation={'kind': 'manual'},
            docs_ref='docs/no_else',
            autofix={'available': False},
            suppression={'state': 'active'},
            source=ViolationSource.NORMALIZED,
        )

        self.assertEqual(violation.schema_version, VIOLATION_SCHEMA_VERSION)
        self.assertEqual(violation.rule_id, 'no_else')
        self.assertEqual(violation.violation_code, 'no_else')
        self.assertEqual(violation.category, 'style')
        self.assertEqual(violation.column_number, 5)
        self.assertEqual(violation.source, ViolationSource.NORMALIZED.value)
        self.assertEqual(violation.to_dict()['schema_version'], VIOLATION_SCHEMA_VERSION)

    def test_from_dict_adapts_legacy_shape(self) -> None:
        legacy_payload = {
            'file_path': 'lib/foo.dart',
            'line_number': 3,
            'line_content': '} else {',
            'message': 'Use early return instead of else.',
            'guard_id': 'no_else',
            'severity': 'error',
            'scope': 'global',
            'location': 'lib/foo.dart:3',
        }

        violation = Violation.from_dict(legacy_payload)

        self.assertEqual(violation.rule_id, 'no_else')
        self.assertEqual(violation.violation_code, 'no_else')
        self.assertEqual(violation.source, ViolationSource.LEGACY.value)
        self.assertEqual(violation.location, 'lib/foo.dart:3')

    def test_internal_error_factory_marks_internal_source(self) -> None:
        violation = Violation.internal_error(
            guard_id='no_else',
            scope=GuardScope.GLOBAL,
            error=RuntimeError('boom'),
        )

        self.assertEqual(violation.file_path, '<internal>')
        self.assertEqual(violation.line_number, 0)
        self.assertEqual(violation.category, 'internal')
        self.assertEqual(violation.source, ViolationSource.INTERNAL.value)
        self.assertEqual(violation.violation_code, 'no_else.internal_error')

    def test_invalid_violation_raises_schema_error(self) -> None:
        with self.assertRaises(ViolationSchemaError):
            Violation.create(
                file_path='',
                message='Use early return instead of else.',
                guard_id='no_else',
            )

    def test_invalid_category_raises_schema_error(self) -> None:
        with self.assertRaises(ViolationSchemaError):
            Violation.create(
                file_path='lib/foo.dart',
                message='Use early return instead of else.',
                guard_id='no_else',
                category='forbidden_pattern',
            )

    def test_ensure_applies_default_category_to_existing_violation(self) -> None:
        violation = Violation.create(
            file_path='lib/foo.dart',
            message='Use early return instead of else.',
            guard_id='no_else',
        )

        normalized = Violation.ensure(
            violation,
            default_category='style',
        )

        self.assertEqual(normalized.category, 'style')


class GuardResultSchemaTest(unittest.TestCase):
    def test_guard_result_normalizes_mapping_violations(self) -> None:
        result = GuardResult(
            guard_id='no_else',
            guard_name='No else',
            description='Use early return.',
            scope=GuardScope.GLOBAL,
            violations=[
                {
                    'file_path': 'lib/foo.dart',
                    'line_number': 3,
                    'line_content': '} else {',
                    'message': 'Use early return instead of else.',
                    'severity': 'error',
                    'scope': 'global',
                },
            ],
            files_scanned=1,
            duration_ms=1.5,
        )

        self.assertEqual(result.result_schema_version, RESULT_SCHEMA_VERSION)
        self.assertEqual(len(result.violations), 1)
        self.assertIsInstance(result.violations[0], Violation)
        self.assertEqual(result.violations[0].guard_id, 'no_else')
        self.assertEqual(result.violations[0].rule_id, 'no_else')


if __name__ == '__main__':
    unittest.main()
