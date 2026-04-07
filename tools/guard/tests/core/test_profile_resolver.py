from __future__ import annotations

import unittest

from tools.guard.core.profile_resolver import ProfileConfigError, ProfileResolver


class ProfileResolverTest(unittest.TestCase):
    def test_resolves_inherited_profile_with_merged_overrides(self) -> None:
        resolver = ProfileResolver.from_config({
            'rule_profiles': {
                'strict': {
                    'severity_overrides': {'folder_structure': 'warning'},
                    'exit_policy': 'strict',
                },
                'ci': {
                    'extends': 'strict',
                    'local_guards': {'feature_completeness': False},
                },
            },
        })

        profile = resolver.resolve('ci')

        self.assertEqual(profile.exit_policy, 'strict')
        self.assertEqual(profile.severity_overrides['folder_structure'], 'warning')
        self.assertFalse(profile.local_guards['feature_completeness'])

    def test_apply_to_config_overlays_runtime_and_guard_maps(self) -> None:
        resolver = ProfileResolver.from_config({
            'rule_profiles': {
                'legacy_migration': {
                    'global_guards': {'icon_style': False},
                    'exit_policy': 'default',
                },
            },
        })

        config, profile = resolver.apply_to_config(
            {
                '_runtime': {'scope': 'all'},
                'global_guards': {'icon_style': True},
            },
            'legacy_migration',
        )

        self.assertEqual(profile.name, 'legacy_migration')
        self.assertFalse(config['global_guards']['icon_style'])
        self.assertEqual(config['_runtime']['profile'], 'legacy_migration')
        self.assertEqual(config['_runtime']['exit_policy'], 'default')

    def test_invalid_inheritance_cycle_fails_fast(self) -> None:
        with self.assertRaises(ProfileConfigError):
            ProfileResolver.from_config({
                'rule_profiles': {
                    'a': {'extends': 'b'},
                    'b': {'extends': 'a'},
                },
            })


if __name__ == '__main__':
    unittest.main()
