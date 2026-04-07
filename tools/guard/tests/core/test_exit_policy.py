from __future__ import annotations

import unittest

from tools.guard.core.exit_policy import ExitPolicy, resolve_active_exit_policy
from tools.guard.core.guard_result import GuardResult, GuardScope, Severity, Violation


def _result_with(severity: Severity) -> GuardResult:
    return GuardResult(
        guard_id='sample',
        guard_name='Sample',
        description='Sample',
        scope=GuardScope.GLOBAL,
        violations=[
            Violation.create(
                file_path='lib/foo.dart',
                message='sample',
                guard_id='sample',
                severity=severity,
                scope=GuardScope.GLOBAL,
            ),
        ],
        files_scanned=1,
        duration_ms=1.0,
    )


class ExitPolicyTest(unittest.TestCase):
    def test_default_policy_fails_on_errors_only(self) -> None:
        policy = ExitPolicy(
            name='default',
            description=None,
            fail_on=frozenset({Severity.ERROR}),
        )

        self.assertTrue(policy.evaluate([_result_with(Severity.ERROR)]).should_fail)
        self.assertFalse(policy.evaluate([_result_with(Severity.WARNING)]).should_fail)

    def test_warning_sensitive_policy_fails_on_warning(self) -> None:
        policy = ExitPolicy(
            name='strict',
            description=None,
            fail_on=frozenset({Severity.ERROR, Severity.WARNING}),
        )

        decision = policy.evaluate([_result_with(Severity.WARNING)])

        self.assertTrue(decision.should_fail)
        self.assertEqual(decision.failed_severities, ('warning',))

    def test_resolve_active_exit_policy_uses_profile_selected_policy(self) -> None:
        config = {
            '_runtime': {'exit_policy': 'strict'},
            'exit_policy': {
                'strict': {'fail_on': ['error', 'warning']},
            },
        }

        policy = resolve_active_exit_policy(config)

        self.assertEqual(policy.name, 'strict')
        self.assertEqual(
            {severity.value for severity in policy.fail_on},
            {'error', 'warning'},
        )

    def test_fail_on_warnings_flag_adds_warning_compatibility_override(self) -> None:
        config = {}

        policy = resolve_active_exit_policy(config, fail_on_warnings=True)

        self.assertEqual(policy.name, 'default')
        self.assertEqual(
            {severity.value for severity in policy.fail_on},
            {'error', 'warning'},
        )


if __name__ == '__main__':
    unittest.main()
