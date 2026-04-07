from __future__ import annotations

from contextlib import redirect_stdout
from io import StringIO
import json
from pathlib import Path
import tempfile
import textwrap
import unittest

from tools.guard.core.formatters import (
    JsonFormatter,
    MarkdownFormatter,
    ReportEnvelope,
    TerminalFormatter,
)
from tools.guard.core.guard_result import GuardResult, GuardScope, Severity, Violation
from tools.guard.core.reporter import Reporter


def _sample_results() -> list[GuardResult]:
    return [
        GuardResult(
            guard_id='no_else',
            guard_name='No else',
            description='Use early return.',
            scope=GuardScope.GLOBAL,
            violations=[
                Violation(
                    file_path='lib/foo.dart',
                    line_number=3,
                    line_content='} else {',
                    message='Use early return instead of else.',
                    guard_id='no_else',
                    severity=Severity.ERROR,
                    scope=GuardScope.GLOBAL,
                ),
            ],
            files_scanned=2,
            duration_ms=12.345,
        ),
        GuardResult(
            guard_id='screen_scaffold',
            guard_name='Screen scaffold',
            description='Screens must use shared scaffolds.',
            scope=GuardScope.LOCAL,
            violations=[],
            files_scanned=2,
            duration_ms=2.0,
        ),
    ]


class ReporterGoldenTest(unittest.TestCase):
    def test_write_json_matches_expected_payload(self) -> None:
        reporter = Reporter(project_name='MemoX')
        results = _sample_results()

        with tempfile.TemporaryDirectory() as temp_dir:
            target = Path(temp_dir) / 'reports' / 'guard.json'
            reporter.write_json(results, target)
            payload = json.loads(target.read_text(encoding='utf-8'))

        self.assertEqual(
            payload,
            {
                'summary': {
                    'guards': 2,
                    'errors': 1,
                    'warnings': 0,
                    'infos': 0,
                },
                'results': [
                    {
                        'result_schema_version': 2,
                        'guard_id': 'no_else',
                        'guard_name': 'No else',
                        'description': 'Use early return.',
                        'scope': 'global',
                        'passed': False,
                        'files_scanned': 2,
                        'duration_ms': 12.345,
                        'error_count': 1,
                        'warning_count': 0,
                        'info_count': 0,
                        'violations': [
                            {
                                'schema_version': 2,
                                'rule_id': 'no_else',
                                'guard_id': 'no_else',
                                'violation_code': 'no_else',
                                'severity': 'error',
                                'category': None,
                                'scope': 'global',
                                'file_path': 'lib/foo.dart',
                                'line_number': 3,
                                'column_number': None,
                                'end_line_number': None,
                                'end_column_number': None,
                                'location': 'lib/foo.dart:3',
                                'symbol': None,
                                'entity': None,
                                'message': 'Use early return instead of else.',
                                'message_ref': None,
                                'message_args': {},
                                'suggestion': None,
                                'remediation': None,
                                'docs_ref': None,
                                'autofix': None,
                                'suppression': None,
                                'line_content': '} else {',
                                'source': 'legacy',
                            },
                        ],
                    },
                    {
                        'result_schema_version': 2,
                        'guard_id': 'screen_scaffold',
                        'guard_name': 'Screen scaffold',
                        'description': 'Screens must use shared scaffolds.',
                        'scope': 'local',
                        'passed': True,
                        'files_scanned': 2,
                        'duration_ms': 2.0,
                        'error_count': 0,
                        'warning_count': 0,
                        'info_count': 0,
                        'violations': [],
                    },
                ],
            },
        )

    def test_write_markdown_matches_expected_snapshot(self) -> None:
        reporter = Reporter(project_name='MemoX')
        results = _sample_results()

        with tempfile.TemporaryDirectory() as temp_dir:
            target = Path(temp_dir) / 'reports' / 'guard.md'
            reporter.write_markdown(results, target)
            markdown = target.read_text(encoding='utf-8')

        expected = textwrap.dedent(
            """\
            # MemoX Guard Report

            - Guards: 2
            - Errors: 1
            - Warnings: 0
            - Infos: 0

            ## no_else [FAIL]

            - Scope: `global`
            - Files scanned: `2`
            - Duration: `12.35ms`

            - `lib/foo.dart:3` [error] Use early return instead of else.

            ## screen_scaffold [PASS]

            - Scope: `local`
            - Files scanned: `2`
            - Duration: `2.00ms`
            - No violations
            """
        )
        self.assertEqual(markdown, expected)

    def test_render_plain_matches_expected_snapshot(self) -> None:
        reporter = Reporter(project_name='MemoX')
        reporter.console = None
        results = _sample_results()
        stdout = StringIO()

        with redirect_stdout(stdout):
            reporter.render_terminal(results)

        expected = textwrap.dedent(
            """\
            MemoX Guard Summary
            guards=2 errors=1 warnings=0 infos=0
            - no_else scope=global errors=1 warnings=0 infos=0
              - lib/foo.dart:3 [error] Use early return instead of else.
            - screen_scaffold scope=local errors=0 warnings=0 infos=0
            """
        )
        self.assertEqual(stdout.getvalue(), expected)


class FormatterAbstractionTest(unittest.TestCase):
    def test_report_envelope_builds_shared_summary(self) -> None:
        envelope = ReportEnvelope.from_results(_sample_results(), project_name='MemoX')

        self.assertEqual(envelope.report_title, 'MemoX Guard Report')
        self.assertEqual(envelope.summary_title, 'MemoX Guard Summary')
        self.assertEqual(
            envelope.summary.to_dict(),
            {
                'guards': 2,
                'errors': 1,
                'warnings': 0,
                'infos': 0,
            },
        )

    def test_all_formatters_consume_same_envelope(self) -> None:
        envelope = ReportEnvelope.from_results(_sample_results(), project_name='MemoX')

        json_payload = json.loads(JsonFormatter(envelope).render())
        markdown = MarkdownFormatter(envelope).render()
        plain = TerminalFormatter(envelope, console=None).render_plain()

        self.assertEqual(json_payload['summary'], envelope.summary.to_dict())
        self.assertIn('# MemoX Guard Report', markdown)
        self.assertIn('MemoX Guard Summary', plain)
        self.assertIn('Use early return instead of else.', markdown)
        self.assertIn('Use early return instead of else.', plain)


if __name__ == '__main__':
    unittest.main()
