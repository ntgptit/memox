from __future__ import annotations

from pathlib import Path
import unittest

import yaml

from tools.guard.core.guard_registry import GuardRegistry
from tools.guard.core.path_constants import PathConstants
from tools.guard.core.guard_result import GuardScope


class GuardRegistryTest(unittest.TestCase):
    def test_registry_discovers_global_and_local_families(self) -> None:
        root = Path(__file__).resolve().parents[4]
        config = yaml.safe_load((root / 'tools/guard/config.yaml').read_text(encoding='utf-8'))
        rules = yaml.safe_load((root / 'tools/guard/project_rules.yaml').read_text(encoding='utf-8'))
        paths = PathConstants.from_config(root, config)
        registry = GuardRegistry(config=config, path_constants=paths, project_rules=rules)

        global_guards = registry.create_guards(family='global')
        local_guards = registry.create_guards(family='local')

        self.assertTrue(global_guards)
        self.assertTrue(local_guards)
        self.assertTrue(all(guard.SCOPE == GuardScope.GLOBAL for guard in global_guards))
        self.assertTrue(all(guard.SCOPE == GuardScope.LOCAL for guard in local_guards))


if __name__ == '__main__':
    unittest.main()
